-----------------------------------
-- Simplified Empyrean weapon acquisition (4-player private server).
--
-- Retail Empyrean weapons require Trial of the Magians + dozens of NM
-- pops in Abyssea zones to gather trophy items (Heavy_Metals, etc.) for
-- each trial step. This module bypasses the trial grind: pin an Empyrean
-- slot, the next onGameIn grants the lv85 base Empyrean weapon (Empyreans
-- start at _85, unlike Mythics/Relics which start at _75).
--
-- All 13 unique Empyrean weapons are verified in `sql/item_basic.sql` at
-- sequential IDs 19456-19468. Job assignments verified against bg-wiki
-- Empyrean_Weapons page. Magian trial chain handles 85 -> 90 -> 95 ->
-- 99 -> ilvl 119 upgrades for those who want them.
--
-- Usage:
--   !setvar Empyrean_Selection N    (1-13, see table below)
--   then zone / relog
--
-- Costs settings main.EMPYREAN_GRANT_COST in Imperial Standing (default
-- 50000, matching Mythic/Relic).
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.empyrean = xi.empyrean or {}

local empyreanPinVar = 'Empyrean_Selection'

-- 13 unique Empyrean weapons. Many are shared across jobs (e.g. Twashtar
-- = THF/BRD/DNC). The `jobs` field lists every retail-equippable job.
local empyreanWeapons =
{
    [ 1] = { name = 'Verethragna',  itemId = 19456, jobs = 'MNK/PUP'                 },
    [ 2] = { name = 'Twashtar',     itemId = 19457, jobs = 'THF/BRD/DNC'             },
    [ 3] = { name = 'Almace',       itemId = 19458, jobs = 'RDM/PLD/BLU'             },
    [ 4] = { name = 'Caladbolg',    itemId = 19459, jobs = 'PLD/DRK'                 },
    [ 5] = { name = 'Farsha',       itemId = 19460, jobs = 'WAR/BST'                 },
    [ 6] = { name = 'Ukonvasara',   itemId = 19461, jobs = 'WAR'                     },
    [ 7] = { name = 'Redemption',   itemId = 19462, jobs = 'DRK'                     },
    [ 8] = { name = 'Rhongomiant',  itemId = 19463, jobs = 'DRG'                     },
    [ 9] = { name = 'Kannagi',      itemId = 19464, jobs = 'NIN'                     },
    [10] = { name = 'Masamune',     itemId = 19465, jobs = 'SAM'                     },
    [11] = { name = 'Gambanteinn',  itemId = 19466, jobs = 'WHM'                     },
    [12] = { name = 'Hvergelmir',   itemId = 19467, jobs = 'BLM/SMN/SCH'             },
    [13] = { name = 'Gandiva',      itemId = 19468, jobs = 'RNG'                     },
}

xi.empyrean.tryGrant = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(empyreanPinVar)
    if pinned == 0 then
        return false
    end

    local entry = empyreanWeapons[pinned]
    if not entry then
        player:printToPlayer(string.format('Empyrean_Selection %d is not valid (1-%d). See empyrean.lua.', pinned, #empyreanWeapons))
        player:setCharVar(empyreanPinVar, 0)
        return true
    end

    local cost = xi.settings.main.EMPYREAN_GRANT_COST or 50000
    local standing = player:getCurrency('imperial_standing')
    if cost > 0 and standing < cost then
        player:printToPlayer(string.format('%s grant costs %d Imperial Standing. You have %d.', entry.name, cost, standing))
        player:setCharVar(empyreanPinVar, 0)
        return true
    end

    if player:hasItem(entry.itemId) then
        player:printToPlayer(string.format('You already own %s.', entry.name))
        player:setCharVar(empyreanPinVar, 0)
        return true
    end

    if not npcUtil.giveItem(player, entry.itemId) then
        player:printToPlayer(string.format('Inventory full — %s not granted. Make space and retry.', entry.name))
        return true -- leave pin set so retry on next zone works
    end

    if cost > 0 then
        player:delCurrency('imperial_standing', cost)
    end

    player:setCharVar(empyreanPinVar, 0)
    player:printToPlayer(string.format('%s (Empyrean lv85, for %s) granted. Upgrade via Magian Moogles in Ru\'Lude Gardens.', entry.name, entry.jobs))

    return true
end
