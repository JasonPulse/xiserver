-----------------------------------
-- Eschan hub NPC services (Affi / Dremi / Shiftrix + Register of Deeds).
--
-- Upstream LSB never implemented any of the Eschan service NPCs. The real
-- client menu is one multi-page event (Affi = 9704, a 10KB program) whose
-- full tree is decoded from the client DAT (see the reference-escha-hub-menu
-- memory + Escha-RuAun dialog 7532-7560). Top menu routes to: key-item shop,
-- grisly-trinket notes, obtain/return/check vorseal, temp items, explanations.
--
-- Earn side: Geas Fete NM kills award escha_silt + escha_beads (see
-- geas_fete.lua grantRewards).
-----------------------------------
require('scripts/globals/npc_util')
require('scripts/globals/domain_invasion')
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
-- The 16 retail vorseal lines in exact client-menu order (DAT msg 7542).
-- `menuIndex` = the line's slot in that menu (1-16), so the decoded event
-- selection maps straight to the line. Prices per tier are retail (bg-wiki
-- Vorseal page). Lines 1-3 have a Domain-Invasion-unlocked advanced form
-- (advKey/advMods) — Regen+ / Refresh+ / Acc.++; the advanced tier is only
-- purchasable once its DI dragon-kill gate is met. Per-tier magnitudes are
-- unpublished on the wiki; the mod steps below are our tuning.
xi.eschanHub.vorsealLines =
{
    { menuIndex =  1, key = 'HPMP',   name = 'HP+, MP+',              price = 1200,  maxTier = 11, mods = { { xi.mod.HPP, 2 }, { xi.mod.MPP, 2 } }, advKey = 'REGEN',   advName = 'Regen+',   advMods = { { xi.mod.REGEN, 3 } } },
    { menuIndex =  2, key = 'ACCEVA', name = 'Acc.+, Eva.+',          price = 600,   maxTier = 11, mods = { { xi.mod.ACC, 6 }, { xi.mod.EVA, 6 } }, advKey = 'REFRESH', advName = 'Refresh+', advMods = { { xi.mod.REFRESH, 1 } } },
    { menuIndex =  3, key = 'DEF',    name = 'DEF+',                  price = 600,   maxTier = 11, mods = { { xi.mod.DEF, 10 } }, advKey = 'ACC2', advName = 'Acc.++', advMods = { { xi.mod.ACC, 10 } } },
    { menuIndex =  4, key = 'ATK',    name = 'Atk.+, Rng. Atk.+',     price = 600,   maxTier = 11, mods = { { xi.mod.ATT, 6 }, { xi.mod.RATT, 6 } } },
    { menuIndex =  5, key = 'MACC',   name = 'Mag. Acc.+, Mag. Eva.+', price = 600,  maxTier = 11, mods = { { xi.mod.MACC, 6 }, { xi.mod.MEVA, 6 } } },
    { menuIndex =  6, key = 'MDEF',   name = 'Mag. Def.+',            price = 600,   maxTier = 11, mods = { { xi.mod.MDEF, 3 } } },
    { menuIndex =  7, key = 'MATT',   name = 'Mag. Atk.+',            price = 600,   maxTier = 11, mods = { { xi.mod.MATT, 3 } } },
    { menuIndex =  8, key = 'DEXAGI', name = 'DEX+, AGI+',            price = 800,   maxTier = 11, mods = { { xi.mod.DEX, 4 }, { xi.mod.AGI, 4 } } },
    { menuIndex =  9, key = 'STRVIT', name = 'STR+, VIT+',            price = 800,   maxTier = 11, mods = { { xi.mod.STR, 4 }, { xi.mod.VIT, 4 } } },
    { menuIndex = 10, key = 'INTMND', name = 'INT+, MND+, CHR+',      price = 800,   maxTier = 11, mods = { { xi.mod.INT, 4 }, { xi.mod.MND, 4 }, { xi.mod.CHR, 4 } } },
    { menuIndex = 11, key = 'OCCNULL', name = 'Occ. ignore damage',   price = 10000, maxTier = 3,  mods = { { xi.mod.NULL_DAMAGE, 1 } } },
    { menuIndex = 12, key = 'KILLER', name = 'Killer+',               price = 10000, maxTier = 3,  mods = {
        { xi.mod.VERMIN_KILLER, 3 }, { xi.mod.BIRD_KILLER, 3 }, { xi.mod.AMORPH_KILLER, 3 }, { xi.mod.LIZARD_KILLER, 3 },
        { xi.mod.AQUAN_KILLER, 3 }, { xi.mod.PLANTOID_KILLER, 3 }, { xi.mod.BEAST_KILLER, 3 }, { xi.mod.UNDEAD_KILLER, 3 },
        { xi.mod.ARCANA_KILLER, 3 }, { xi.mod.DRAGON_KILLER, 3 }, { xi.mod.DEMON_KILLER, 3 }, { xi.mod.EMPTY_KILLER, 3 },
        { xi.mod.HUMANOID_KILLER, 3 }, { xi.mod.LUMINIAN_KILLER, 3 }, { xi.mod.LUMINION_KILLER, 3 } } },
    { menuIndex = 13, key = 'DT',     name = 'Dmg. Taken-',           price = 10000, maxTier = 3,  mods = { { xi.mod.DMG, -100 } } }, -- -1%/tier (DMG /10000)
    { menuIndex = 14, key = 'SPOILS', name = 'Spoils+',               price = 50000, maxTier = 11, mods = {} }, -- drop-rate handled at loot time, no combat mod
    { menuIndex = 15, key = 'RAREENEMY', name = 'Rare Enemy+',        price = 1000,  maxTier = 11, mods = {} }, -- lottery-rate hook, no combat mod
    { menuIndex = 16, key = 'LUCK',   name = 'Luck+',                 price = 1000,  maxTier = 11, mods = {} }, -- reduces portal silt cost, no combat mod
}

local vorsealVar = function(key)
    return 'Vorseal_' .. key
end

xi.eschanHub.vorsealTier = function(player, key)
    return player:getCharVar(vorsealVar(key))
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
-- Affi / Dremi / Shiftrix — native vendor event (CSID 9704).
--
-- DRAFT / DECODE INSTRUMENT. Upstream never implemented this NPC, so the
-- exact 9704 param protocol (which startEvent slot carries silt, what
-- option each menu pick returns, what updateEvent renders each sub-page)
-- is unknown. This handler:
--   * opens 9704 with the silt balance in the sparkshop-style slot layout,
--   * logs EVERY onEventUpdate/onEventFinish option under all candidate
--     decodes so a live navigation session reveals the true protocol,
--   * echoes the balance back via updateEvent so the client will actually
--     advance to sub-pages during that session (sparkshop pattern),
--   * performs the real vorseal purchase once the layout is confirmed
--     (buyVorsealTier below is protocol-agnostic and already correct).
--
-- Modeled on scripts/globals/sparkshop.lua (the canonical paginated
-- points vendor): category = option & 0xFF, selection = option >> 16,
-- qty = (option >> 10) & 0x3F. Those masks are the STARTING HYPOTHESIS
-- for 9704 and will be corrected from the logged captures next session.
-----------------------------------

-- Fire the balance into several slots so whichever one the client reads for
-- "(N silt)" in the menu header lights up — the screenshot tells us which.
xi.eschanHub.onSageTrigger = function(player, npcName, mapKi)
    local silt  = player:getCurrency('escha_silt')
    local beads = player:getCurrency('escha_beads')

    printf('[EschaSage:%s] startEvent(9704) silt=%d beads=%d', npcName, silt, beads)
    player:setLocalVar('EschaSageMapKi', mapKi)
    player:startEvent(9704, 0, silt, beads, silt, 0, 0, 0, silt)
end

-- Dump one option value under every decode we might need, so the live logs
-- pin the real layout without guesswork.
local logOption = function(tag, npcName, option)
    printf('[EschaSage:%s] %s option=%d 0x%08X | low8=%d >>8=%d >>16=%d (>>10&0x3F)=%d (>>2&0xF)=%d (>>6&0xF)=%d',
        npcName, tag, option, option,
        bit.band(option, 0xFF),
        bit.rshift(option, 8),
        bit.rshift(option, 16),
        bit.band(bit.rshift(option, 10), 0x3F),
        bit.band(bit.rshift(option, 2), 0xF),
        bit.band(bit.rshift(option, 6), 0xF))
end

xi.eschanHub.onSageEventUpdate = function(player, npcName, csid, option)
    if csid ~= 9704 then
        return
    end

    logOption('UPDATE', npcName, option)

    -- Keep the menu alive so navigation reaches every sub-page: echo the
    -- current silt in the sparkshop-style reply shapes (6-param and 2-param
    -- variants both observed in sparkshop; send the wide one).
    local silt = player:getCurrency('escha_silt')
    player:updateEvent(silt, silt, 0, 0, 0, silt)
end

xi.eschanHub.onSageEventFinish = function(player, npcName, csid, option)
    if csid ~= 9704 then
        return
    end

    logOption('FINISH', npcName, option)
end

-- Protocol-agnostic vorseal purchase. Once the live session maps a menu
-- selection to a vorseal line index + tier, the finish/update handler calls
-- this. It is already correct regardless of how the option is decoded.
xi.eschanHub.buyVorsealTier = function(player, npcName, lineIndex)
    local line = xi.eschanHub.vorsealLines[lineIndex]
    if not line then
        return false
    end

    local tier = xi.eschanHub.vorsealTier(player, line.key)
    if tier >= line.maxTier then
        player:printToPlayer(string.format('%s: Your %s vorseal is already at its zenith.', npcName, line.name), xi.msg.channel.NS_SAY)
        return false
    end

    local silt = player:getCurrency('escha_silt')
    if silt < line.price then
        return false
    end

    -- Remove the aggregate buff BEFORE the tier changes so onEffectLose
    -- subtracts exactly what onEffectGain added, then re-apply.
    player:delStatusEffectSilent(xi.effect.VORSEAL)
    player:setCharVar(vorsealVar(line.key), tier + 1)
    player:delCurrency('escha_silt', line.price)
    xi.eschanHub.applyVorseals(player)
    return true
end

-----------------------------------
-- Register of Deeds — Domain Points rewards (Zurim's full catalog, usable
-- in-zone). Click: prints the category list. Trade a page number (1-10):
-- prints that page's items as absolute catalog numbers (page * 100 + n).
-- Trade an absolute number: buys the item.
-----------------------------------
local flattenPage = function(page)
    local flat = {}
    for _, subpage in ipairs(page) do
        for _, entry in ipairs(subpage) do
            table.insert(flat, entry)
        end
    end

    return flat
end

-- Reverse lookup id -> enum name for catalog display. Built once on load.
local itemNames = {}
for name, id in pairs(xi.item) do
    if type(id) == 'number' and not itemNames[id] then
        itemNames[id] = string.lower(string.gsub(name, '_', ' '))
    end
end

xi.eschanHub.onRegisterTrigger = function(player)
    local points = player:getCurrency('domain_points')
    player:printToPlayer(string.format('Register of Deeds: You hold %d domain points. Trade gil equal to a page number to browse.', points), xi.msg.channel.NS_SAY)

    for pageNum, label in ipairs(xi.domainInvasion.rewardStockPages) do
        player:printToPlayer(string.format('[%2d] %s', pageNum, label), xi.msg.channel.NS_SAY)
    end
end

xi.eschanHub.onRegisterTrade = function(player, trade)
    local selection = trade:getGil()

    if selection == 0 or trade:getItemCount() ~= 0 then
        return false
    end

    -- Page browse (1-10)
    if selection <= #xi.domainInvasion.rewardStock then
        local flat = flattenPage(xi.domainInvasion.rewardStock[selection])
        player:printToPlayer(string.format('-- %s --', xi.domainInvasion.rewardStockPages[selection]), xi.msg.channel.NS_SAY)

        for i, entry in ipairs(flat) do
            player:printToPlayer(string.format('[%3d] %s — %d DP', selection * 100 + i, itemNames[entry.item] or tostring(entry.item), entry.cost), xi.msg.channel.NS_SAY)
        end

        return false -- browsing keeps the gil in the trade window
    end

    -- Purchase (absolute catalog number)
    local pageNum = math.floor(selection / 100)
    local index   = selection % 100
    local page    = xi.domainInvasion.rewardStock[pageNum]

    if not page then
        player:printToPlayer('Register of Deeds: That is not a catalog number. Click me for the page list.', xi.msg.channel.NS_SAY)
        return false
    end

    local entry = flattenPage(page)[index]
    if not entry then
        player:printToPlayer('Register of Deeds: That is not a catalog number on that page.', xi.msg.channel.NS_SAY)
        return false
    end

    local points = player:getCurrency('domain_points')
    if points < entry.cost then
        player:printToPlayer(string.format('Register of Deeds: That costs %d domain points — you hold %d.', entry.cost, points), xi.msg.channel.NS_SAY)
        return false
    end

    if not npcUtil.giveItem(player, entry.item) then
        return false
    end

    player:delCurrency('domain_points', entry.cost)
    player:confirmTrade()
    player:printToPlayer(string.format('Register of Deeds: Recorded. %d domain points remaining.', points - entry.cost), xi.msg.channel.NS_SAY)
    return true
end
