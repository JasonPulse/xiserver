-----------------------------------
-- Eschan hub NPC services (Affi / Dremi / Shiftrix + Register of Deeds).
--
-- Upstream LSB never implemented any of the Eschan service NPCs. The real
-- client menu is one multi-menu event blob shared by entity 17957449; each
-- csid is a JUMP entry point into it (decoded from the client DAT via
-- xidat/eschavendor.py). The VENDOR top menu is csid 9700 (msg 7556, the
-- 7532-family "What do you do?" list) with every option enabled by the
-- event's own hard-coded bitmask (data[26]=1022). csid 9704 is only the leaf
-- "Which do you choose?" picker (msg 7537) — correctly used by the Geas Fete
-- pop menu below, but it is NOT the vendor (the all-day 9704 confusion).
-- Top menu routes to: key-item shop (7534), grisly-trinket notes (7536),
-- obtain vorseal (7542), return vorseal (7546), check blessings (7561), temp
-- items. Selection encoding for this whole blob is option = selectedRow << 8
-- (row 1 = 0x100), proven by the working pop-menu picker in the same blob.
--
-- Earn side: Geas Fete NM kills award escha_silt + escha_beads (see
-- geas_fete.lua grantRewards).
-----------------------------------
require('scripts/globals/npc_util')
require('scripts/globals/geas_fete')
-----------------------------------
xi = xi or {}
xi.eschanHub = xi.eschanHub or {}

-----------------------------------
-- Retail pop menu (Affi / Dremi / Shiftrix — client event 9704).
--
-- Live-probe findings (2026-07-21, puppet session):
--   * 9704 renders "Which do you choose?" listing the player's owned Geas
--     Fete pop key items for the zone; entries the server doesn't back are
--     drawn as '-' and the widget paginates via event updates (same family
--     as Zurim's 9512 catalog).
--   * startEvent(9704, 0, 1) produced the cleanest first window.
--   * onEventFinish option is the 1-based index of the pick (0 = None);
--     0x40000000-flagged options on update are page requests.
-- The option→entry mapping is echoed to the player on pop so a mismatch is
-- visible immediately; logs capture every code for correction.
-----------------------------------
local popContext = {}

local ownedPopsForZone = function(player, zoneId)
    local owned = {}
    for kiId, entry in pairs(xi.geasFete.pops) do
        if entry.zoneId == zoneId and player:hasKeyItem(kiId) then
            table.insert(owned, { kiId = kiId, label = entry.label })
        end
    end

    table.sort(owned, function(a, b)
        return a.kiId < b.kiId
    end)

    return owned
end

xi.eschanHub.onPopMenuTrigger = function(player, zoneId)
    local owned = ownedPopsForZone(player, zoneId)
    popContext[player:getID()] = owned

    if #owned == 0 then
        player:printToPlayer('You hold no pop key items for this land. Defeat its denizens or trade for their trophies first.', xi.msg.channel.NS_SAY)
        return
    end

    player:startEvent(9704, 0, 1)
end

xi.eschanHub.onPopMenuUpdate = function(player, csid, option)
    -- Page request: keep the window alive.
    if bit.band(option, 0x40000000) ~= 0 then
        player:updateEvent(0, 1)
    end
end

xi.eschanHub.onPopMenuFinish = function(player, csid, option)
    local owned = popContext[player:getID()]
    popContext[player:getID()] = nil

    if not owned or option == 0 or bit.band(option, 0x40000000) ~= 0 then
        return
    end

    -- Decoded live (2026-07-21 puppet session): the client returns the
    -- chosen entry as (index << 8), index 1-based into the same owned-pop-KI
    -- list the server built (both ordered by key-item id). Row 1 = 0x100.
    local index = bit.rshift(option, 8)
    local entry = owned[index]
    if not entry then
        player:printToPlayer(string.format('That selection did not match a held pop item (option 0x%X).', option), xi.msg.channel.NS_SAY)
        return
    end

    local _, msg = xi.geasFete.popBoss(player, entry.kiId)
    player:printToPlayer(msg, xi.msg.channel.NS_SAY)
end

-- Vorseals — retail model: each line is bought tier by tier with silt and
-- the unlock is PERMANENT (CharVar per line). All owned tiers aggregate
-- into one VORSEAL status effect applied on Escha zone entry (see
-- scripts/effects/vorseal.lua and the three Zone.lua onZoneIn hooks).
-- The 19 vorseal lines in exact client-menu order (DAT msg 7542): the 16
-- base lines plus the last-page trio Regen+/Refresh+/Acc.++. `menuIndex` =
-- the line's slot in that menu (1-19), so the decoded event selection maps
-- straight to the line (display row d = vorsealLines[d + 1]). Prices and
-- per-tier mod steps are retail (bg-wiki Vorseal page: HP/MP +20 flat,
-- Acc/RAcc/Eva +2, DEF and Atk/RAtk +1%, magic lines +2, attributes +3,
-- Occ/Killer/DT 1%, Regen/Refresh +1, Acc.++ +5).
xi.eschanHub.vorsealLines =
{
    { menuIndex =  1, key = 'HPMP',   name = 'HP+, MP+',              price = 1200,  maxTier = 11, mods = { { xi.mod.HP, 20 }, { xi.mod.MP, 20 } } },
    { menuIndex =  2, key = 'ACCEVA', name = 'Acc.+, Eva.+',          price = 600,   maxTier = 11, mods = { { xi.mod.ACC, 2 }, { xi.mod.RACC, 2 }, { xi.mod.EVA, 2 } } },
    { menuIndex =  3, key = 'DEF',    name = 'DEF+',                  price = 600,   maxTier = 11, mods = { { xi.mod.DEFP, 1 } } },
    { menuIndex =  4, key = 'ATK',    name = 'Atk.+, Rng. Atk.+',     price = 600,   maxTier = 11, mods = { { xi.mod.ATTP, 1 }, { xi.mod.RATTP, 1 } } },
    { menuIndex =  5, key = 'MACC',   name = 'Mag. Acc.+, Mag. Eva.+', price = 600,  maxTier = 11, mods = { { xi.mod.MACC, 2 }, { xi.mod.MEVA, 2 } } },
    { menuIndex =  6, key = 'MDEF',   name = 'Mag. Def.+',            price = 600,   maxTier = 11, mods = { { xi.mod.MDEF, 2 } } },
    { menuIndex =  7, key = 'MATT',   name = 'Mag. Atk.+',            price = 600,   maxTier = 11, mods = { { xi.mod.MATT, 2 } } },
    { menuIndex =  8, key = 'DEXAGI', name = 'DEX+, AGI+',            price = 800,   maxTier = 11, mods = { { xi.mod.DEX, 3 }, { xi.mod.AGI, 3 } } },
    { menuIndex =  9, key = 'STRVIT', name = 'STR+, VIT+',            price = 800,   maxTier = 11, mods = { { xi.mod.STR, 3 }, { xi.mod.VIT, 3 } } },
    { menuIndex = 10, key = 'INTMND', name = 'INT+, MND+, CHR+',      price = 800,   maxTier = 11, mods = { { xi.mod.INT, 3 }, { xi.mod.MND, 3 }, { xi.mod.CHR, 3 } } },
    { menuIndex = 11, key = 'OCCNULL', name = 'Occ. ignore damage',   price = 10000, maxTier = 3,  mods = { { xi.mod.NULL_DAMAGE, 1 } } },
    { menuIndex = 12, key = 'KILLER', name = 'Killer+',               price = 10000, maxTier = 3,  mods = {
        { xi.mod.VERMIN_KILLER, 1 }, { xi.mod.BIRD_KILLER, 1 }, { xi.mod.AMORPH_KILLER, 1 }, { xi.mod.LIZARD_KILLER, 1 },
        { xi.mod.AQUAN_KILLER, 1 }, { xi.mod.PLANTOID_KILLER, 1 }, { xi.mod.BEAST_KILLER, 1 }, { xi.mod.UNDEAD_KILLER, 1 },
        { xi.mod.ARCANA_KILLER, 1 }, { xi.mod.DRAGON_KILLER, 1 }, { xi.mod.DEMON_KILLER, 1 }, { xi.mod.EMPTY_KILLER, 1 },
        { xi.mod.HUMANOID_KILLER, 1 }, { xi.mod.LUMINIAN_KILLER, 1 }, { xi.mod.LUMINION_KILLER, 1 } } },
    { menuIndex = 13, key = 'DT',     name = 'Dmg. Taken-',           price = 10000, maxTier = 3,  mods = { { xi.mod.DMG, -100 } } }, -- -1%/tier (DMG /10000)
    { menuIndex = 14, key = 'SPOILS', name = 'Spoils+',               price = 50000, maxTier = 11, mods = {} }, -- drop-rate handled at loot time, no combat mod
    { menuIndex = 15, key = 'RAREENEMY', name = 'Rare Enemy+',        price = 1000,  maxTier = 11, mods = {} }, -- lottery-rate hook, no combat mod
    { menuIndex = 16, key = 'LUCK',   name = 'Luck+',                 price = 1000,  maxTier = 11, mods = {} }, -- reduces portal silt cost, no combat mod
    -- The three "advanced" lines occupy the buy list's last page (display
    -- rows 16-18). On retail they unlock via Domain Invasion; here they are
    -- first-class buyable lines like the rest (caps follow the same kill
    -- milestones), so all vorseals are available.
    { menuIndex = 17, key = 'REGEN',   name = 'Regen+',               price = 1500,  maxTier = 11, mods = { { xi.mod.REGEN, 1 } } },
    { menuIndex = 18, key = 'REFRESH', name = 'Refresh+',             price = 1500,  maxTier = 11, mods = { { xi.mod.REFRESH, 1 } } },
    { menuIndex = 19, key = 'ACC2',    name = 'Acc.++',               price = 1500,  maxTier = 11, mods = { { xi.mod.ACC, 5 } } },
}

local vorsealVar = function(key)
    return 'Vorseal_' .. key
end

xi.eschanHub.vorsealTier = function(player, key)
    return player:getCharVar(vorsealVar(key))
end

-- Retail progressive vorseal cap (per line: min(cap, line.maxTier)).
-- Ladder: 1-2 RoV progression, 3-5 all tier-1/2/3 Zi'Tah Geas Fete NMs,
-- 6-8 Ru'Aun tiers, 9 Domain Invasion dragons, 10 zone bosses,
-- 11 Reisenjima HELM NMs. Standing in Escha already implies the RoV
-- baseline, so the floor is 2; kill milestones bump the Vorseal_Cap
-- CharVar (tier rosters pend BG-wiki verification before the bump hooks
-- go into geas_fete.lua/domain_invasion.lua — do not guess rosters).
xi.eschanHub.vorsealCap = function(player)
    return math.max(2, player:getCharVar('Vorseal_Cap'))
end

-- Retail cap milestones (bg-wiki Vorseal): tiers unlock per line as the
-- character's Eschan kill counters grow (counted in mobs.lua
-- onMobDeathEx). The ten primary lines share the all-monsters counter;
-- Occ/Killer/DT and Spoils use the NM counter (the former max at tier 3).
-- Rare Enemy+ and Luck+ unlock via quest lines on retail (unmapped here)
-- and hold at the floor.
local killMilestones = { 10, 50, 100, 500, 1000, 5000, 10000, 25000, 50000, 75000, 110000 }
local nmMilestones   = { 10, 25, 50, 100, 200, 350, 550, 800, 1100, 1500, 2000 }

local lineCounters =
{
    OCCNULL   = 'nm',
    KILLER    = 'nm',
    DT        = 'nm',
    SPOILS    = 'nm',
    RAREENEMY = 'quest',
    LUCK      = 'quest',
}

local milestoneTier = function(count, milestones)
    local tier = 0
    for _, needed in ipairs(milestones) do
        if count < needed then
            break
        end

        tier = tier + 1
    end

    return tier
end

-- Cap for one line as the client should DISPLAY it (the Y in X/Y) — also
-- what buyVorsealTier enforces. vorsealCap (the RoV-baseline floor of 2,
-- raisable via the Vorseal_Cap CharVar) backstops the milestone tiers.
xi.eschanHub.vorsealLineCap = function(player, key)
    for _, line in ipairs(xi.eschanHub.vorsealLines) do
        if line.key == key then
            local tier    = 0
            local counter = lineCounters[key]
            if counter == 'nm' then
                tier = milestoneTier(player:getCharVar('EschaNMKills'), nmMilestones)
            elseif counter ~= 'quest' then
                tier = milestoneTier(player:getCharVar('EschaKills'), killMilestones)
            end

            return math.min(math.max(tier, xi.eschanHub.vorsealCap(player)), line.maxTier)
        end
    end

    return 0
end

-- Buy-list cap DISPLAY (the Y in X/Y). Decoded from the client event VM
-- (Escha-ZiTah entity 17957449): the buy-list build loop counts, for each
-- set bit in a 185-bit mask, +1 into the row's cap. So the rendered cap of
-- each row = the number of set mask bits assigned to it, and a row with 0
-- shows/hides accordingly (retail: a line is hidden until its first
-- milestone). The mask is num[1..6] (six 32-bit words, bits 0..184) of the
-- reply to value query OPTION 8; capBitRow[i] gives the 0-based display row
-- that bit-slot i (word = i//32, bit = i%32) belongs to. Display row order:
-- 0-15 = vorsealLines[1..16], 16/17/18 = the advanced Regen/Refresh/Acc.++.
-- (num[i] -> client WkZone[i+2]; word0 = num[1]. Silt/owned come from
-- startEvent and are unaffected, so only query 8 carries this mask.)
local capBitRow =
{
    1, 2, 3, 4, 5, 6, 14, 1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 1, 2, 3, 4, 5, 6,
    1, 2, 3, 4, 5, 6, 7, 8, 9, 15, 7, 8, 9, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5,
    6, 1, 2, 3, 4, 5, 6, 7, 8, 9, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 1, 2,
    3, 4, 5, 6, 15, 15, 14, 14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 13, 13, 13,
    13, 13, 13, 13, 13, 13, 13, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 17,
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 7, 8, 9, 15, 14, 7, 8, 9, 15, 15,
    14, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 1, 2, 3, 4, 5, 6, 1, 2, 3,
    4, 5, 6, 7, 8, 9, 7, 8, 9, 10, 11, 12, 7, 8, 9, 15, 15, 15, 15, 1, 2, 3, 4,
    5, 6, 14, 14, 14, 14, 14,
}

-- Build the six 32-bit mask words that make query 8's reply render each
-- row's real cap: set the first capOf(row) of that row's bit-slots. Display
-- row d maps directly to vorsealLines[d + 1] (all 19 lines, in order).
xi.eschanHub.buildVorsealCapMask = function(player)
    local capOf = {}
    for d = 0, 18 do
        capOf[d] = xi.eschanHub.vorsealLineCap(player, xi.eschanHub.vorsealLines[d + 1].key)
    end

    local words = { 0, 0, 0, 0, 0, 0 }
    local used  = {}
    for i = 0, #capBitRow - 1 do
        local d = capBitRow[i + 1]
        used[d] = used[d] or 0
        if used[d] < (capOf[d] or 0) then
            local w = math.floor(i / 32) + 1
            words[w] = bit.bor(words[w], bit.lshift(1, i % 32))
            used[d] = used[d] + 1
        end
    end

    return words
end

-- Reapply the aggregate buff. Order matters: the effect script reads the
-- CharVars on gain AND on lose, so the old effect must be removed BEFORE
-- a tier changes (see onSageTrade purchase flow).
xi.eschanHub.applyVorseals = function(player)
    local total = 0
    for _, line in ipairs(xi.eschanHub.vorsealLines) do
        total = total + xi.eschanHub.vorsealTier(player, line.key)
    end

    if total == 0 then
        return
    end

    if not player:hasStatusEffect(xi.effect.VORSEAL) then
        player:addStatusEffect(xi.effect.VORSEAL, total, 0, 7200)
    end
end

-----------------------------------
-- Affi / Dremi / Shiftrix — native vendor event (CSID 9700, the top menu).
--
-- The client owns the whole menu tree and drives navigation from its own
-- bytecode; the server only unblocks each yield with updateEvent(<balances>)
-- (which refreshes the silt count shown) and performs the silt transaction.
-- The event stays open so the player keeps shopping — never terminate in
-- update. onEventFinish just clears the per-player navigation stage.
--
-- Menu tree + encoding are decoded from the client DAT (all row<<8):
--   TOP (7556/7532)  row 0 Nothing | 1 key items | 2 trinket notes |
--                    3 OBTAIN vorseal | 4 RETURN vorseal | 5 CHECK | 6 temp
--   VORSEAL LIST (7542)  row 0 back | 1-16 = vorsealLines[menuIndex]
--   QUANTITY (7543)      row 0 none | Q = buy Q seals (tiers) of the line
-- Because each menu yields separately, the server tracks which menu the
-- player is in with a localvar stage + the selected line.
-----------------------------------
-- Vendor top-menu csid PER NPC. The vorseal menus live in the Eschan
-- conflux entity's event data[], and the csid differs by zone:
--   Affi (Escha-ZiTah): 9700 — CONFIRMED (DAT: its event data[] carries the
--     vorseal menus 7542/7556/7534, and the live !cs 9700 rendered it).
--   Dremi (Escha-RuAun) / Shiftrix (Reisenjima): the same menus are served by
--     a DIFFERENT entity there — that zone's 9700 event has NO vorseal data —
--     so their csid is unknown until an in-zone !cs sweep pins it. Left
--     unmapped so they cleanly report "not attuned" instead of firing the
--     wrong event and mis-decoding a purchase.
-- Vendor event is 9701 (9700 = greeting that chains to it), confirmed live via
-- the 0x034 packet. The full "What would you like to do?" menu (DAT MENU 7556
-- @622, bitmask forced to 1022 = all options at @617) is reached ONLY when the
-- client's unlock bitmask routes there. The client maps num[i] -> WkZone[i+2]
-- (live-calibrated: num[1] renders as "current silt" via L9 <- Z3; the portal
-- event 9100 bit-tests Z4 = num[2] against the Escha zone ids 288/289/291).
-- The event bit-extracts Z4 = num[2]: bits 0-15 (L10) = which vorseal lines
-- show, bits 24-31 (L13) route the top menu (@604: L13 == 1 -> full menu @617).
-- The old handler put beads in num[2] (high byte 0 -> L13 = 0), so it never
-- reached the full menu -> only "Nothing / Hear explanations" rendered.
-- Dremi/Shiftrix use a different entity/csid per zone (unmapped, pending sweep).
local vendorCsid =
{
    Affi = 9701,
}

-- num[2] unlock value sent to the client. LIVE-VERIFIED 2026-07-22 via
-- !cs (= startEvent with these params, no server changes):
--   bits 24-31 = introduction stage. 0/1 -> locked 2-option menu, 2 ->
--     3-option menu (+ key items / trinket notes), 3 -> FULL 6-option vendor
--     menu (+ check vorseal effects / receive temporary items /
--     explanations), 4+ -> falls back to the locked menu.
--   bits 0-23 = line/stock bits (kept set; visibility of the six rows above
--     proved insensitive to them, the remaining obtain/return rows are gated
--     by the mid-event value queries answered in onSageEventUpdate).
local vorsealUnlockMask = 0x03000000 + 0xFFFF

local stageTop = 0 -- at the top menu

xi.eschanHub.onSageTrigger = function(player, npcName, mapKi)
    local csid = vendorCsid[npcName]
    if not csid then
        player:printToPlayer(string.format('%s: This conflux is not yet attuned for vorseal trade. Visit Affi in Escha - Zi\'Tah.', npcName), xi.msg.channel.NS_SAY)
        return
    end

    local silt  = player:getCurrency('escha_silt')
    local beads = player:getCurrency('escha_beads')

    player:setLocalVar('EschaSageMapKi', mapKi)
    player:setLocalVar('EschaVendorCsid', csid)
    player:setLocalVar('EschaVendorStage', stageTop)
    player:setLocalVar('EschaVendorLine', 0)

    -- num[1] = silt (the "current silt" display), num[2] = unlock bitmask
    -- (-> Z4), num[3] = beads, num[4-6] = owned tier nibbles (4 bits per
    -- vorseal line in list order, 8 lines per slot — the buy list's
    -- "owned/max" counts; every PENDINGNUM slot was ruled out live).
    local tiers = { 0, 0, 0 }
    for i, line in ipairs(xi.eschanHub.vorsealLines) do
        local slot  = math.floor((i - 1) / 8) + 1
        local shift = ((i - 1) % 8) * 4
        tiers[slot] = tiers[slot] + bit.lshift(xi.eschanHub.vorsealTier(player, line.key), shift)
    end

    player:startEvent(csid, 0, silt, vorsealUnlockMask, beads, tiers[1], tiers[2], tiers[3])
end

xi.eschanHub.onSageEventUpdate = function(player, npcName, csid, option)
    if csid ~= vendorCsid[npcName] then
        return
    end

    print(string.format('[eschanHub] %s csid %d option %d', player:getName(), csid, option))

    -- Purchase (live-decoded): picking a line in the 7542 buy list sends
    -- option = (qty << 8+8) | (clientLineId << 8) | 5, where clientLineId =
    -- vorsealLines menuIndex - 1 (Acc bought live as 0x010105 -> line byte 1,
    -- qty 1). buyVorsealTier guards funds and tier caps, so a mis-decode can
    -- browse but never mis-debit.
    local action = bit.band(option, 0xFF)
    if action == 5 and option > 0xFF then
        local lineId = bit.band(bit.rshift(option, 8), 0xFF)
        local qty    = bit.band(bit.rshift(option, 16), 0xFF)
        xi.eschanHub.buyVorsealTier(player, npcName, lineId + 1, qty)
    end

    -- Answer the client's value queries. Mode 1 (CharVar EschaCalMode, set
    -- via !setplayervar) feeds EschaCal0..7 verbatim for live slot probing;
    -- mode 2 answers option*100+slot so displays identify their source.
    -- Default: the payload the full flow renders under (status + action
    -- menu + buy/return lists all verified live with these values).
    local calMode = player:getCharVar('EschaCalMode')
    if calMode == 1 then
        -- Per-query overrides first (EschaCalQ<option>_<slot>), falling
        -- back to the shared EschaCal<slot>: the client assembles some
        -- display variables from bit-ranges of DIFFERENT query replies,
        -- so uniform answers cannot isolate them.
        local vals = {}
        for slot = 0, 7 do
            local v = player:getCharVar(string.format('EschaCalQ%d_%d', option, slot))
            if v == 0 then
                v = player:getCharVar('EschaCal' .. slot)
            end

            vals[slot + 1] = v
        end

        player:updateEvent(vals[1], vals[2], vals[3], vals[4], vals[5], vals[6], vals[7], vals[8])
    elseif calMode == 2 then
        local base = option * 100
        player:updateEvent(base + 1, base + 2, base + 3, base + 4, base + 5, base + 6, base + 7, base + 8)
    elseif option == 8 then
        -- Query 8 carries the cap-DISPLAY mask: num[1..6] are the six 32-bit
        -- words whose set bits the client counts into each row's cap (see
        -- buildVorsealCapMask). num[0]/num[7] stay route-safe. Rows whose cap
        -- is 0 (locked / advanced lines) hide, which is retail-correct.
        local w = xi.eschanHub.buildVorsealCapMask(player)
        player:updateEvent(255, w[1], w[2], w[3], w[4], w[5], w[6], 0)
    elseif option == 14 or option == 9 then
        -- The other greeting/menu value queries. They do not feed the cap
        -- digits (proven live: caps track query 8 only), but a sparse reply
        -- can hide rows, so answer with a dense filler. Fresh-open silt/
        -- owned displays come from startEvent, not these replies.
        local dense = 0x07654321
        player:updateEvent(dense, dense, dense, dense, dense, dense, dense, dense)
    else
        -- Purchase and any other mid-event option: full live mirror of
        -- the startEvent layout (slot 1 = silt, 2 = unlock mask, 3 =
        -- beads, 4-6 = owned tier nibbles), recomputed on every answer —
        -- the post-purchase reply is what refreshes the client's
        -- session-cached silt/owned displays (proven live).
        local silt  = player:getCurrency('escha_silt')
        local beads = player:getCurrency('escha_beads')
        local tiers = { 0, 0, 0 }
        for i, line in ipairs(xi.eschanHub.vorsealLines) do
            local slot  = math.floor((i - 1) / 8) + 1
            local shift = ((i - 1) % 8) * 4
            tiers[slot] = tiers[slot] + bit.lshift(xi.eschanHub.vorsealTier(player, line.key), shift)
        end

        player:updateEvent(255, silt, vorsealUnlockMask, beads, tiers[1], tiers[2], tiers[3], 0)
    end
end

xi.eschanHub.onSageEventFinish = function(player, npcName, csid, option)
    player:setLocalVar('EschaVendorStage', stageTop)
    player:setLocalVar('EschaVendorLine', 0)
end

-- Buy `count` tiers (seals) of a vorseal line in one confirm, retail-style
-- (the 7543 "how many" menu). Stops at the line's tier cap and when silt runs
-- out, debiting only for tiers actually granted.
xi.eschanHub.buyVorsealTier = function(player, npcName, lineIndex, count)
    local line = xi.eschanHub.vorsealLines[lineIndex]
    if not line then
        return false
    end

    count = count or 1
    local tier    = xi.eschanHub.vorsealTier(player, line.key)
    local lineCap = xi.eschanHub.vorsealLineCap(player, line.key)
    if tier >= lineCap then
        player:printToPlayer(string.format('%s: Your %s vorseal is already at its zenith.', npcName, line.name), xi.msg.channel.NS_SAY)
        return false
    end

    -- How many tiers can we actually afford / are allowed this confirm.
    local silt    = player:getCurrency('escha_silt')
    local wanted  = math.min(count, lineCap - tier)
    local canPay  = math.floor(silt / line.price)
    local buying  = math.min(wanted, canPay)
    if buying <= 0 then
        return false
    end

    -- Remove the aggregate buff BEFORE the tiers change so onEffectLose
    -- subtracts exactly what onEffectGain added, then re-apply.
    player:delStatusEffectSilent(xi.effect.VORSEAL)
    player:setCharVar(vorsealVar(line.key), tier + buying)
    player:delCurrency('escha_silt', line.price * buying)
    xi.eschanHub.applyVorseals(player)
    return true
end

-- Return a vorseal line (7546): drop it one tier and refund nothing (retail
-- return just frees the slot). Bounded to owned tiers.
xi.eschanHub.returnVorseal = function(player, npcName, lineIndex)
    local line = xi.eschanHub.vorsealLines[lineIndex]
    if not line then
        return false
    end

    local tier = xi.eschanHub.vorsealTier(player, line.key)
    if tier <= 0 then
        return false
    end

    player:delStatusEffectSilent(xi.effect.VORSEAL)
    player:setCharVar(vorsealVar(line.key), tier - 1)
    xi.eschanHub.applyVorseals(player)
    return true
end

-----------------------------------
-- Register of Deeds — Domain Points rewards (Zurim's full catalog, usable
-- in-zone). Click: prints the category list. Trade a page number (1-10):
-- prints that page's items as absolute catalog numbers (page * 100 + n).
-- Trade an absolute number: buys the item.
-----------------------------------
-- Register of Deeds — RETAIL is a kill-records book, not a shop (the old
-- gil-as-page-number DP browser was a custom hack, removed at user request;
-- DP rewards stay on Zurim's catalog). Native client event 9708 (decoded from
-- the DAT): top menu 7678 "What will you verify?" routes to the defeated-NM
-- star pages 7679/7680 (choice bit N = NM defeated, drawn as a star) and the
-- victory tallies 7681. The menus pull their gate/cursor/bitmask and the star
-- bits from server updateEvent replies (event VM 0x06 requests), so the
-- handler answers every update with the player's actual kill records.
--
-- Star bit order = the client's fixed choice indexes in each zone's star
-- pages (Zi'Tah 7679/7680; Ru'Aun 7798/7799 and Reisenjima 7825/7826 pending
-- dialog decode — their books render with zero stars until filled).
local registerBookStars =
{
    [xi.zone.ESCHA_ZITAH] =
    {
        [0]  = 'Wepwawet',
        [1]  = 'Lustful_Lydia',
        [2]  = 'Aglaophotis',
        [3]  = 'Tangata_Manu',
        [4]  = 'Vidala',
        [5]  = 'Gestalt',
        [6]  = 'Angrboda',
        [7]  = 'Cunnast',
        [8]  = 'Revetaur',
        [9]  = 'Ferrodon',
        [10] = 'Gulltop',
        [11] = 'Vyala',
        [12] = 'Blazewing',
        [13] = 'Alpluachra', -- Bucca/Puca/Alpluachra share one line
        [16] = 'Pazuzu',
        [17] = 'Wrathare',
        [18] = 'Ionos',
        [19] = 'Sensual_Sandy',
        [20] = 'Nosoi',
        [21] = 'Brittlis',
        [22] = 'Kamohoalii',
        [23] = 'Umdhlebi',
        [24] = 'Fleetstalker',
        [25] = 'Shockmaw',
        [26] = 'Urmahlullu',
    },
}

local registerBookCsid = 9708

local registerRecords = function(player)
    local stars = 0
    local nmCount = 0
    local zoneStars = registerBookStars[player:getZoneID()]
    if zoneStars then
        for bitIndex, mobName in pairs(zoneStars) do
            if player:getCharVar(string.format('GeasFete_%s_Defeated', mobName)) > 0 then
                stars = bit.bor(stars, bit.lshift(1, bitIndex))
                nmCount = nmCount + 1
            end
        end
    end

    return stars, nmCount
end

xi.eschanHub.onRegisterTrigger = function(player)
    local stars, nmCount = registerRecords(player)
    player:startEvent(registerBookCsid, 0, stars, nmCount, 0, 0, 0)
end

xi.eschanHub.onRegisterEventUpdate = function(player, csid, option)
    if csid ~= registerBookCsid then
        return
    end

    -- Answer the client's value requests: gate 0 (show), cursor 0, full menu
    -- bitmask, then the record values. Positional hypothesis (requests fill
    -- in order) — calibrate on the first live pass after deploy.
    local stars, nmCount = registerRecords(player)
    player:updateEvent(0, 0, 0xFFFF, stars, nmCount, 0)
end

xi.eschanHub.onRegisterTrade = function(player, trade)
    -- Records book takes no trades.
    return false
end
