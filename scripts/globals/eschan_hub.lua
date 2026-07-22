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
-- LIVE-VERIFIED 2026-07-21: 9701 is the vendor event (9700 = greeting that
-- chains to it). The full "Obtain a vorseal" menu is gated behind the retail
-- "Hear various explanations" (10 silt) step, unlocked SERVER-SIDE within the
-- event — NOT by a param or key item (both ruled out live). onSageEventUpdate
-- must process the explanation pick to open the vendor; the unlocked-menu
-- option codes still need one post-deploy live capture. Dremi/Shiftrix use a
-- different entity/csid per zone (unmapped, pending in-zone sweep).
local vendorCsid =
{
    Affi = 9701,
}

local topObtainVorseal = 3
local topReturnVorseal = 4

local stageTop    = 0 -- at the top menu (7556)
local stageObtain = 1 -- at the vorseal list (7542)
local stageQty    = 2 -- at the quantity menu (7543)
local stageReturn = 3 -- at the return list (7546)

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
    player:startEvent(csid, 0, silt, beads, 0, 0, 0)
end

xi.eschanHub.onSageEventUpdate = function(player, npcName, csid, option)
    if csid ~= vendorCsid[npcName] then
        return
    end

    local row   = bit.rshift(option, 8) -- selection encoding for this event blob
    local stage = player:getLocalVar('EschaVendorStage')
    local silt  = player:getCurrency('escha_silt')
    local beads = player:getCurrency('escha_beads')

    if stage == stageTop then
        -- Route the top-menu pick; other rows (key items / trinket notes /
        -- check / temp) are drawn by the client, nothing to debit here.
        if row == topObtainVorseal then
            player:setLocalVar('EschaVendorStage', stageObtain)
        elseif row == topReturnVorseal then
            player:setLocalVar('EschaVendorStage', stageReturn)
        end
    elseif stage == stageObtain then
        if row >= 1 and row <= #xi.eschanHub.vorsealLines then
            player:setLocalVar('EschaVendorLine', row)
            player:setLocalVar('EschaVendorStage', stageQty)
        else
            player:setLocalVar('EschaVendorStage', stageTop) -- "No vorseals for now"
        end
    elseif stage == stageQty then
        local line = player:getLocalVar('EschaVendorLine')
        if row >= 1 and line >= 1 then
            xi.eschanHub.buyVorsealTier(player, npcName, line, row)
            silt = player:getCurrency('escha_silt')
        end

        player:setLocalVar('EschaVendorStage', stageObtain) -- client returns to the list
    elseif stage == stageReturn then
        if row >= 1 and row <= #xi.eschanHub.vorsealLines then
            xi.eschanHub.returnVorseal(player, npcName, row)
        end

        player:setLocalVar('EschaVendorStage', stageTop)
    end

    -- Answer the client's mid-event value requests. The top menu (DAT @622)
    -- draws MENU cursor=WkLocal[1] bitmask=WkLocal[0]; the event requests
    -- WkLocal[0..2] via opcode 0x06, and the 0x05C PENDINGNUM num[i] fills
    -- WkLocal[i] by index. So the shop bitmask MUST land in num[0]:
    --   updateEvent(bitmask, cursor, ...) -> num[0]=bitmask, num[1]=cursor.
    -- 1022 (0x3FE) = top-menu options 1-9 enabled (data[26] in the DAT). Put
    -- the silt/bead balances in high slots so they can't collide with the
    -- gate (WkLocal[2]); the exact balance-display slot is the only thing to
    -- calibrate on the first live pass (cosmetic — options already show).
    -- NOTE: updateEvent drops zero-valued args, preserving the slot index,
    -- so leading zeros would shift everything — the bitmask goes FIRST.
    player:updateEvent(1022, 0, 0, 0, 0, silt, beads, 0)
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
    local tier = xi.eschanHub.vorsealTier(player, line.key)
    if tier >= line.maxTier then
        player:printToPlayer(string.format('%s: Your %s vorseal is already at its zenith.', npcName, line.name), xi.msg.channel.NS_SAY)
        return false
    end

    -- How many tiers can we actually afford / are allowed this confirm.
    local silt    = player:getCurrency('escha_silt')
    local wanted  = math.min(count, line.maxTier - tier)
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
