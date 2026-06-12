-----------------------------------
-- Simplified Mythic weapon acquisition (4-player private server).
--
-- Retail mythics gate behind a long quest chain (Magnificent Mossbed →
-- Stop! Imposter! → Pulling the Strings), 49 Dynamis-Bastok runs to pop
-- the Goldsmith NM, plus 50,000 Alexandrite contributed to the Trial of
-- the Magians. This module bypasses the chain entirely: player pins a
-- mythic slot, the next onGameIn grants the base (lv75) mythic for that
-- slot. Upgrade trials still go through Magian Moogles (already wired).
--
-- Usage:
--   !setvar Mythic_Selection N    (1-20, see table below)
--   then zone / relog
--
-- Costs settings main.MYTHIC_GRANT_COST in Imperial Standing (default
-- 50000). Set to 0 to give them away free.
--
-- 18 of 22 jobs have a mythic in retail; the four (BLU lacks one until
-- 2010 patch; SCH and DNC came later; PUP late) are all covered here.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.mythic = xi.mythic or {}

local mythicPinVar = 'Mythic_Selection'

-- All canonical mythic weapons. Names match item_basic.sql entries.
local mythicWeapons =
{
    [ 1] = { job = 'WAR', name = 'Conqueror',     itemId = 18971 },
    [ 2] = { job = 'MNK', name = 'Glanzfaust',    itemId = 18972 },
    [ 3] = { job = 'WHM', name = 'Yagrush',       itemId = 18973 },
    [ 4] = { job = 'BLM', name = 'Laevateinn',    itemId = 18974 },
    [ 5] = { job = 'RDM', name = 'Murgleis',      itemId = 18975 },
    [ 6] = { job = 'THF', name = 'Twashtar',      itemId = 19398 },
    [ 7] = { job = 'PLD', name = 'Burtgang',      itemId = 18977 },
    [ 8] = { job = 'DRK', name = 'Liberator',     itemId = 18978 },
    [ 9] = { job = 'BST', name = 'Aymur',         itemId = 18979 },
    [10] = { job = 'BRD', name = 'Carnwenhan',    itemId = 18980 },
    [11] = { job = 'RNG', name = 'Gastraphetes',  itemId = 18981 },
    [12] = { job = 'SAM', name = 'Kogarasumaru',  itemId = 18982 },
    [13] = { job = 'NIN', name = 'Nagi',          itemId = 18983 },
    [14] = { job = 'DRG', name = 'Ryunohige',     itemId = 18984 },
    [15] = { job = 'SMN', name = 'Tupsimati',     itemId = 18970 },
    [16] = { job = 'BLU', name = 'Tizona',        itemId = 18986 },
    [17] = { job = 'COR', name = 'Death Penalty', itemId = 18987 },
    [18] = { job = 'PUP', name = 'Kenkonken',     itemId = 18988 },
    [19] = { job = 'DNC', name = 'Terpsichore',   itemId = 18969 },
    [20] = { job = 'SCH', name = 'Idris',         itemId = 21070 },
}

xi.mythic.tryGrant = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(mythicPinVar)
    if pinned == 0 then
        return false
    end

    local entry = mythicWeapons[pinned]
    if not entry then
        player:printToPlayer(string.format('Mythic_Selection %d is not valid (1-%d). See mythic.lua.', pinned, #mythicWeapons))
        player:setCharVar(mythicPinVar, 0)
        return true
    end

    local cost = xi.settings.main.MYTHIC_GRANT_COST or 50000
    local standing = player:getCurrency('imperial_standing')
    if cost > 0 and standing < cost then
        player:printToPlayer(string.format('%s grant costs %d Imperial Standing. You have %d.', entry.name, cost, standing))
        player:setCharVar(mythicPinVar, 0)
        return true
    end

    if player:hasItem(entry.itemId) then
        player:printToPlayer(string.format('You already own %s.', entry.name))
        player:setCharVar(mythicPinVar, 0)
        return true
    end

    if not npcUtil.giveItem(player, entry.itemId) then
        player:printToPlayer(string.format('Inventory full — %s not granted. Make space and retry.', entry.name))
        return true -- leave pin set so retry on next zone works
    end

    if cost > 0 then
        player:delCurrency('imperial_standing', cost)
    end

    player:setCharVar(mythicPinVar, 0)
    player:printToPlayer(string.format('%s (%s mythic) granted. Upgrade via Magian Moogles in Ru\'Lude Gardens.', entry.name, entry.job))
    return true
end
