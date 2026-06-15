-----------------------------------
-- Simplified Relic weapon acquisition (4-player private server).
--
-- Retail Relic weapons gate behind ~49 Dynamis-Bastok/Sandy/Wind/Jeuno
-- runs to earn the base weapon drop + 100s of additional runs to trade
-- Dynamis currency (Tukuku Whiteshell / Lungo-nango Jadeshell /
-- Ordelle Bronzepiece / Montiont Silverpiece / Byne Bill) for upgrade
-- tiers. This module bypasses the Dynamis grind: pin a relic slot,
-- the next onGameIn grants the lv75 base relic weapon.
--
-- Each of the 14 base relic weapons is verified in `sql/item_basic.sql`
-- at the _75 tier. Upgrade trials still go through Magian Moogles
-- (already wired) — base relic → 80 → 85 → 90 → 99 → ilvl 119 path.
--
-- Usage:
--   !setvar Relic_Selection N    (1-14, see table below)
--   then zone / relog
--
-- Costs settings main.RELIC_GRANT_COST in Imperial Standing (default
-- 50000, matching mythic). Set to 0 to give them away free.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.relic = xi.relic or {}

local relicPinVar = 'Relic_Selection'

local relicWeapons =
{
    [ 1] = { job = 'WAR', name = 'Bravura',       itemId = 18294 },
    [ 2] = { job = 'MNK', name = 'Spharai',       itemId = 18264 },
    [ 3] = { job = 'WHM', name = 'Mjollnir',      itemId = 18324 },
    [ 4] = { job = 'BLM', name = 'Claustrum',     itemId = 18330 },
    [ 5] = { job = 'THF', name = 'Mandau',        itemId = 18270 },
    [ 6] = { job = 'PLD', name = 'Excalibur',     itemId = 18276 },
    [ 7] = { job = 'PLD', name = 'Aegis (shield)', itemId = 15070 },
    [ 8] = { job = 'DRK', name = 'Apocalypse',    itemId = 18306 },
    [ 9] = { job = 'BST', name = 'Guttler',       itemId = 18288 },
    [10] = { job = 'BRD', name = 'Gjallarhorn',   itemId = 18342 },
    [11] = { job = 'RNG', name = 'Annihilator',   itemId = 18336 },
    [12] = { job = 'RNG', name = 'Yoichinoyumi',  itemId = 18348 },
    [13] = { job = 'SAM', name = 'Amanomurakumo', itemId = 18318 },
    [14] = { job = 'NIN', name = 'Kikoku',        itemId = 18312 },
    [15] = { job = 'DRG', name = 'Gungnir',       itemId = 18300 },
}

xi.relic.tryGrant = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(relicPinVar)
    if pinned == 0 then
        return false
    end

    local entry = relicWeapons[pinned]
    if not entry then
        player:printToPlayer(string.format('Relic_Selection %d is not valid (1-%d). See relic.lua.', pinned, #relicWeapons))
        player:setCharVar(relicPinVar, 0)
        return true
    end

    local cost = xi.settings.main.RELIC_GRANT_COST or 50000
    local standing = player:getCurrency('imperial_standing')
    if cost > 0 and standing < cost then
        player:printToPlayer(string.format('%s grant costs %d Imperial Standing. You have %d.', entry.name, cost, standing))
        player:setCharVar(relicPinVar, 0)
        return true
    end

    if player:hasItem(entry.itemId) then
        player:printToPlayer(string.format('You already own %s.', entry.name))
        player:setCharVar(relicPinVar, 0)
        return true
    end

    if not npcUtil.giveItem(player, entry.itemId) then
        player:printToPlayer(string.format('Inventory full — %s not granted. Make space and retry.', entry.name))
        return true -- leave pin set so retry on next zone works
    end

    if cost > 0 then
        player:delCurrency('imperial_standing', cost)
    end

    player:setCharVar(relicPinVar, 0)
    player:printToPlayer(string.format('%s (%s relic, lv75) granted. Upgrade via Magian Moogles in Ru\'Lude Gardens.', entry.name, entry.job))

    return true
end
