--[[
    xi_agent_bridge — Windower 4 addon that exposes a logged-in FFXI client as
    an agent-drivable "puppet" over a newline-delimited-JSON TCP socket.

    It is the live half of the in-game testing harness: the real client does all
    the crypto / decompression / dialog rendering, and this addon just taps the
    event packets, relays GM/chat commands, and injects event responses.

        agent (xi_game.py)  <--JSON/TCP-->  THIS ADDON  <-->  FFXI client <--> LSB

    Install: drop this folder in Windower4/addons/xi_agent_bridge/ and
             `lua load xi_agent_bridge` (or addon.lua autoload). Log a GM
             character in, parked in a zone.

    Protocol
      agent -> addon : {"cmd":"ping"}
                       {"cmd":"send","text":"!cs 100 1 2"}   -- typed as input
                       {"cmd":"answer","option":3,"mode":"end"|"update"}
                       {"cmd":"state"}
      addon -> agent : {"type":"hello","puppet":"windower","char":"..."}
                       {"type":"pong"} / {"type":"ack","cmd":...}
                       {"type":"event_in","id":"0x032","csid":N,"unique_no":..,
                                "act_index":..,"params":[...],"raw":"hex"}
                       {"type":"event_out","id":"0x05b","csid":N,"option":N,"raw":"hex"}
                       {"type":"state","player":{...},"target":{...}}
                       {"type":"error","msg":"..."}

    NOTE ON FIRST RUN: the field names Windower's `packets` library uses for
    0x05B can vary by version. This addon builds 0x05B from the *raw* layout
    taken from LSB src (0x05b_eventend.h) to avoid that dependency, and ALSO
    logs every captured event so you can confirm offsets against a real manual
    selection before trusting `answer`.
]]

_addon.name     = 'xi_agent_bridge'
_addon.author   = 'agent-testing harness'
_addon.version  = '0.1'
_addon.commands = { 'xab' }

local socket  = require('socket')
local packets = require('packets')

local BIND_HOST = '0.0.0.0'   -- listen on all interfaces (reach over Tailscale/LAN)
local BIND_PORT = 27800

-- s2c event packets we relay outward, c2s response we observe.
local EV_IN  = { [0x032] = 'event', [0x033] = 'eventstr', [0x034] = 'eventnum' }
local EV_OUT = { [0x05B] = 'eventend', [0x05C] = 'eventendxzy' }

local server          -- listening socket
local clients = {}    -- connected agent sockets
local active_event = nil  -- last 0x032 seen: {unique_no, act_index, csid}

-------------------------------------------------------------------------------
-- socket plumbing
-------------------------------------------------------------------------------

local function start_server()
    server = socket.tcp()
    server:setoption('reuseaddr', true)
    local ok, err = server:bind(BIND_HOST, BIND_PORT)
    if not ok then
        windower.add_to_chat(123, 'xab: bind failed: ' .. tostring(err))
        return
    end
    server:listen(4)
    server:settimeout(0)
    windower.add_to_chat(207, ('xab: listening on %s:%d'):format(BIND_HOST, BIND_PORT))
end

local function broadcast(tbl)
    local line = require('files') and nil  -- (no-op; keep luac happy if files absent)
    local json = '{'
    -- tiny hand-rolled JSON encoder (avoid extra deps); values are pre-encoded
    for i, kv in ipairs(tbl) do
        json = json .. (i > 1 and ',' or '') .. kv
    end
    json = json .. '}\n'
    for sock, _ in pairs(clients) do
        local ok = sock:send(json)
        if not ok then clients[sock] = nil end
    end
end

-- helpers to build JSON key:value fragments safely
-- Full JSON-string escape: backslash, quote, control chars, newlines, tabs,
-- and any byte < 0x20 (including FFXI's 0x07 multi-line dialog separator).
-- Without this, embedded \n in chat dialog breaks newline-delimited parsing
-- on the agent side.
local function js_escape(v)
    v = tostring(v):gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t')
    v = v:gsub('[%z\1-\31]', function(c) return ('\\u%04x'):format(c:byte()) end)
    return v
end
local function js(k, v) return ('"%s":"%s"'):format(k, js_escape(v)) end
local function jn(k, v) return ('"%s":%s'):format(k, tostring(v)) end
local function jarr(k, t)
    local parts = {}
    for _, x in ipairs(t) do parts[#parts + 1] = tostring(x) end
    return ('"%s":[%s]'):format(k, table.concat(parts, ','))
end

-------------------------------------------------------------------------------
-- base64 encoder (inline; Windower doesn't ship one). Standard Lua base64
-- per the Lua-Users wiki — handles arbitrary binary input.
-------------------------------------------------------------------------------
local B64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_encode(data)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return B64_CHARS:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- Direct socket send of a large payload — broadcast() builds the JSON in
-- memory but screenshot payloads can be >500KB so we send to the single
-- requesting socket rather than fan-out. LuaSocket's `send` may write
-- only part of a large buffer (OS socket buffer is usually 64-256KB) so
-- we loop until every byte is out the door.
local function send_to(sock, payload)
    local frame = payload .. '\n'
    local sent = 0
    local total = #frame
    while sent < total do
        local last, err, partial = sock:send(frame, sent + 1)
        if last then
            sent = last
        elseif partial then
            sent = partial
            if err == 'timeout' then
                -- nothing to do; loop will retry the unsent tail
            else
                clients[sock] = nil
                return
            end
        else
            clients[sock] = nil
            return
        end
    end
end

-------------------------------------------------------------------------------
-- command handling (agent -> addon)
-------------------------------------------------------------------------------

-- inject a 0x05B (event end / update) reusing the active event's target ids.
-- LSB layout (src/map/packets/c2s/0x05b_eventend.h):
--   u32 UniqueNo;    -- body offset 0
--   u32 EndPara;     -- body offset 4 (option chosen)
--   u16 ActIndex;    -- body offset 8
--   u16 Mode;        -- body offset 10 (0=end, 1=update)
--   u16 EventNum;    -- body offset 12 (the CSID — *** this must match ***)
--   u16 EventPara;   -- body offset 14
-- Windower's stock outgoing 0x05B field names: "Target" = UniqueNo,
-- "Option Index" = EndPara, "Target Index" = ActIndex, "Automated Message"
-- = Mode, "Zone" = EventNum (despite the misleading name), "Menu ID" =
-- EventPara. The prior bridge had "Menu ID" mapped to CSID — wrong, that
-- offset is EventPara. EventNum (CSID) lands in the "Zone" field.
local function send_answer(option, mode)
    if not active_event then
        return false, 'no active event captured yet (trigger a !cs first)'
    end
    local p = packets.new('outgoing', 0x05B)
    p['Target']        = active_event.unique_no
    p['Option Index']  = option
    p['Target Index']  = active_event.act_index
    p['Automated Message'] = (mode == 'update') and 1 or 0
    p['Zone']          = active_event.csid -- LSB's EventNum
    p['Menu ID']       = 0                  -- LSB's EventPara
    packets.inject(p)
    return true
end

local function handle_cmd(sock, msg)
    local cmd = msg:match('"cmd"%s*:%s*"(%a+)"')
    if cmd == 'ping' then
        sock:send('{"type":"pong"}\n')
    elseif cmd == 'send' then
        -- Greedy capture up to the LAST `"` before the closing `}` so
        -- chat commands with embedded `\"` (e.g. /ja "Vivacious Pulse"
        -- <me>) survive. The lazy `(.-)"` would stop at the first inner
        -- quote and truncate the command. We unescape JSON `\"` back to
        -- raw `"` before forwarding to windower.send_command.
        local text = msg:match('"text"%s*:%s*"(.*)"%s*}')
        if text then
            text = text:gsub('\\"', '"'):gsub('\\\\', '\\')
            windower.send_command('input ' .. text)
            sock:send('{"type":"ack","cmd":"send"}\n')
        else
            sock:send('{"type":"error","msg":"send missing text"}\n')
        end
    elseif cmd == 'answer' then
        local option = tonumber(msg:match('"option"%s*:%s*(-?%d+)'))
        local mode = msg:match('"mode"%s*:%s*"(%a+)"') or 'end'
        -- Optional manual overrides for cases where active_event wasn't
        -- captured (probe started after the 0x032 fired). Use the live
        -- character's pos as the default Target/ActIndex.
        local csidOverride = tonumber(msg:match('"csid"%s*:%s*(-?%d+)'))
        if csidOverride and not active_event then
            local pl = windower.ffxi.get_player()
            if pl then
                active_event = {
                    unique_no = pl.id,
                    act_index = pl.index,
                    csid = csidOverride,
                }
            end
        elseif csidOverride and active_event then
            active_event.csid = csidOverride
        end
        local ok, err = send_answer(option or 0, mode)
        if ok then sock:send('{"type":"ack","cmd":"answer"}\n')
        else sock:send('{"type":"error","msg":"' .. tostring(err) .. '"}\n') end
    elseif cmd == 'state' then
        local pl = windower.ffxi.get_player() or {}
        local mob = windower.ffxi.get_mob_by_target('t') or {}
        broadcast({
            js('type', 'state'),
            js('player', pl.name or ''),
            jn('hpp', pl.vitals and pl.vitals.hpp or 0),
            js('target', mob.name or ''),
            jn('target_index', mob.index or 0),
        })
    elseif cmd == 'screenshot' then
        -- Snapshot the puppet client and base64-encode over the existing
        -- socket. Windower can save .bmp / .jpg / .png depending on its
        -- config; we accept any image extension and pick the newest file
        -- that wasn't there before the screenshot command ran.
        local dir = windower.windower_path .. 'screenshots/'
        local function is_image(name)
            local ext = name:sub(-4):lower()
            return ext == '.png' or ext == '.jpg' or ext == '.bmp'
        end
        local before = {}
        for _, name in ipairs(windower.get_dir(dir) or {}) do
            if is_image(name) then before[name] = true end
        end
        -- Windower 4 screenshot addon syntax: `screenshot <BMP/PNG/JPG> [hide]`.
        -- PNG keeps files small enough to base64 back over the socket; `hide`
        -- drops the UI/HUD so captures are clean for OCR / visual inspection.
        windower.send_command('screenshot PNG hide')
        coroutine.schedule(function()
            local latest_name = nil
            local listing = windower.get_dir(dir) or {}
            for _, name in ipairs(listing) do
                if is_image(name) and not before[name] then
                    if name > (latest_name or '') then
                        latest_name = name
                    end
                end
            end
            if not latest_name then
                -- Include the dir listing in the error so the agent can
                -- see what's actually there.
                local sample = {}
                for i = 1, math.min(5, #listing) do sample[i] = listing[i] end
                send_to(sock, ('{"type":"error","msg":"screenshot: no new image in %s","existing_count":%d,"sample":%q}')
                    :format(dir, #listing, table.concat(sample, ',')))
                return
            end
            local f = io.open(dir .. latest_name, 'rb')
            if not f then
                send_to(sock, '{"type":"error","msg":"screenshot: cannot open ' .. latest_name .. '"}')
                return
            end
            local data = f:read('*a')
            f:close()
            local b64 = base64_encode(data)
            send_to(sock, ('{"type":"screenshot","name":"%s","bytes":%d,"data":"%s"}'):format(latest_name, #data, b64))
        end, 1.2)
    else
        sock:send('{"type":"error","msg":"unknown cmd"}\n')
    end
end

-------------------------------------------------------------------------------
-- packet taps (game -> agent)
-------------------------------------------------------------------------------

windower.register_event('incoming chunk', function(id, data)
    local kind = EV_IN[id]
    if not kind then return end
    local hex = data:hex():gsub(' ', '')
    if id == 0x032 then
        -- LSB 0x032 (s2c) packet body (see src/map/packets/s2c/0x032_event.cpp):
        --   u32 UniqueNo;   // body offset 0  (Windower pos 5)
        --   u16 ActIndex;   // body offset 4  (Windower pos 9)
        --   u16 EventNum;   // body offset 6  (Windower pos 11) — actually the ZONE id, not the CSID
        --   u16 EventPara;  // body offset 8  (Windower pos 13) — *** THIS is the actual CSID ***
        --   u16 Mode;       // body offset 10 (Windower pos 15)
        --   u16 EventNum2;  // body offset 12 — zone again
        --   u16 EventPara2; // body offset 14 — upper flags
        local unique = data:unpack('I4', 5)
        local act    = data:unpack('H', 9)
        local csid   = data:unpack('H', 13)
        active_event = { unique_no = unique, act_index = act, csid = csid }
        local p = packets.parse('incoming', data)
        local params = {}
        for i = 0, 7 do params[#params + 1] = p['Data ' .. i] or 0 end
        broadcast({
            js('type', 'event_in'), js('id', '0x032'),
            jn('csid', csid), jn('unique_no', unique), jn('act_index', act),
            jarr('params', params), js('raw', hex),
        })
    else
        broadcast({ js('type', 'event_in'), js('id', ('0x%03x'):format(id)),
                    js('kind', kind), js('raw', hex) })
    end
end)

windower.register_event('outgoing chunk', function(id, data)
    if not EV_OUT[id] then return end
    local hex = data:hex():gsub(' ', '')
    if id == 0x05B then
        local option = data:unpack('I4', 9)   -- EndPara at body+4
        local csid   = data:unpack('H', 17)   -- EventNum
        broadcast({ js('type', 'event_out'), js('id', '0x05b'),
                    jn('csid', csid), jn('option', option), js('raw', hex) })
    else
        broadcast({ js('type', 'event_out'), js('id', ('0x%03x'):format(id)),
                    js('raw', hex) })
    end
end)

-- Chat / dialog text capture. Fires for every line that lands in the chat
-- log — NPC say, system message, printToPlayer output, etc. We forward
-- every line as JSON so the agent can read event dialog directly without
-- screenshots. Mode reference: 6 = system_1 (printToPlayer default),
-- 144 = system, 150 = NPC say, 151 = NPC shout, etc.
--
-- IMPORTANT: we deliberately ignore the `blocked` flag — some Windower
-- addons (autoexec, etc.) flag system messages as blocked but the message
-- has still been generated and is meaningful to the agent. Dropping
-- blocked messages hides printToPlayer output for tests like sky_access
-- warps, Mog Garden tutorial, mythic grant flows.
windower.register_event('incoming text', function(original, modified, original_mode, modified_mode, blocked)
    local text = original or modified
    if not text or text == '' then return end
    -- Strip auto-translate sentinels for cleaner agent input.
    text = text:gsub('\30.', ''):gsub('\31.', '')
    broadcast({
        js('type', 'chat'),
        jn('mode', original_mode or 0),
        js('text', text),
        jn('blocked', blocked and 1 or 0),
    })
end)

-------------------------------------------------------------------------------
-- main poll loop
-------------------------------------------------------------------------------

windower.register_event('prerender', function()
    if not server then return end
    -- accept new agents
    local client = server:accept()
    if client then
        client:settimeout(0)
        clients[client] = ''
        local pl = windower.ffxi.get_player()
        client:send(('{"type":"hello","puppet":"windower","char":"%s"}\n')
            :format(pl and pl.name or ''))
    end
    -- read pending lines from each agent
    for sock, buf in pairs(clients) do
        local chunk, err = sock:receive('*l')
        if chunk then
            handle_cmd(sock, chunk)
        elseif err == 'closed' then
            clients[sock] = nil
        end
    end
end)

windower.register_event('load', start_server)

windower.register_event('unload', function()
    for sock, _ in pairs(clients) do pcall(function() sock:close() end) end
    if server then pcall(function() server:close() end) end
end)

windower.register_event('addon command', function(cmd)
    if cmd == 'status' then
        local n = 0
        for _ in pairs(clients) do n = n + 1 end
        windower.add_to_chat(207, ('xab: %d agent(s) connected, active_event=%s')
            :format(n, active_event and active_event.csid or 'none'))
    end
end)
