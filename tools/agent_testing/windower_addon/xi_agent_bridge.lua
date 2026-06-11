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
local function js(k, v) return ('"%s":"%s"'):format(k, tostring(v):gsub('"', '\\"')) end
local function jn(k, v) return ('"%s":%s'):format(k, tostring(v)) end
local function jarr(k, t)
    local parts = {}
    for _, x in ipairs(t) do parts[#parts + 1] = tostring(x) end
    return ('"%s":[%s]'):format(k, table.concat(parts, ','))
end

-------------------------------------------------------------------------------
-- command handling (agent -> addon)
-------------------------------------------------------------------------------

-- inject a 0x05B (event end / update) reusing the active event's target ids.
-- Layout from LSB 0x05b_eventend.h:
--   u32 UniqueNo; u32 EndPara(option); u16 ActIndex; u16 Mode; u16 EventNum(csid); u16 EventPara
local function send_answer(option, mode)
    if not active_event then
        return false, 'no active event captured yet (trigger a !cs first)'
    end
    local p = packets.new('outgoing', 0x05B)
    -- Field names here follow Windower's stock 0x05B definition; if your version
    -- differs, check the logged event_out and adjust these keys.
    p['Target'] = active_event.unique_no
    p['Target Index'] = active_event.act_index
    p['Menu ID'] = active_event.csid
    p['Option Index'] = option
    p['_unknown1'] = (mode == 'update') and 1 or 0
    packets.inject(p)
    return true
end

local function handle_cmd(sock, msg)
    local cmd = msg:match('"cmd"%s*:%s*"(%a+)"')
    if cmd == 'ping' then
        sock:send('{"type":"pong"}\n')
    elseif cmd == 'send' then
        local text = msg:match('"text"%s*:%s*"(.-)"')
        if text then
            windower.send_command('input ' .. text:gsub('\\"', '"'))
            sock:send('{"type":"ack","cmd":"send"}\n')
        else
            sock:send('{"type":"error","msg":"send missing text"}\n')
        end
    elseif cmd == 'answer' then
        local option = tonumber(msg:match('"option"%s*:%s*(-?%d+)'))
        local mode = msg:match('"mode"%s*:%s*"(%a+)"') or 'end'
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
        -- raw parse of the known head: u32 UniqueNo, u16 ActIndex, u16 EventNum...
        local unique = data:unpack('I4', 5)   -- packet body starts at byte 5 (after 4-byte header)
        local act    = data:unpack('H', 9)
        local csid   = data:unpack('H', 11)
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
