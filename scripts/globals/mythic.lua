-----------------------------------
-- Simplified Mythic weapon acquisition (4-player private server).
--
-- Retail mythics gate behind a long quest chain (Magnificent Mossbed →
-- Stop! Imposter! → Pulling the Strings), 49 Dynamis-Bastok runs to pop
-- the Goldsmith NM, plus 50,000 Alexandrite contributed to the Trial of
-- the Magians. This module bypasses the quest chain entirely: player
-- pins a mythic slot, the next onGameIn grants a usable mythic for that
-- slot.
--
-- Grant tier per job:
--   * 18 of 20 jobs: granted the **lv75 mythic** (e.g. YAGRUSH_75).
--     Magian Moogles in Ru'Lude Gardens have full trial paths from _75
--     through _99 / ilvl 119 — verified against
--     scripts/globals/magian_data.lua trial entries.
--   * THF (Twashtar) and SCH (Idris): granted the **ilvl 119 finished
--     version** (TWASHTAR_119_III = 20587, IDRIS_119_II = 21080). These
--     two mythics have **no Magian trial path** in this server's
--     magian_data.lua (Twashtar/Idris were added later in retail's
--     lifecycle and use different progression). Granting a finished
--     version keeps the system complete for those jobs.
--
-- Usage:
--   !setvar Mythic_Selection N    (1-20, see table below)
--   then zone / relog
--
-- Costs settings main.MYTHIC_GRANT_COST in Imperial Standing (default
-- 50000). Set to 0 to give them away free.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.mythic = xi.mythic or {}

local mythicPinVar = 'Mythic_Selection'

-- 20 retail Mythic weapons (verified against bg-wiki Mythic_Weapons),
-- granted at _75 (Magian trial start point). Plus 2 Ergon weapons
-- (Idris=GEO, Epeolatry=RUN) added with newer jobs — no Magian chain
-- documented, so granted at ilvl 119 final form.
--
-- Earlier mapping errors corrected on 2026-06-15 after bg-wiki audit:
--   slot 6 THF was Twashtar (Empyrean) -> now Vajra (THF Mythic)
--   slot 15 SMN was Tupsimati -> now Nirvana (SMN Mythic, Tupsimati is SCH)
--   slot 20 SCH was Idris (GEO Ergon) -> now Tupsimati (SCH Mythic)
-- GEO Ergon (Idris) and RUN Ergon (Epeolatry) added as slots 21-22.
local mythicWeapons =
{
    [ 1] = { job = 'WAR', name = 'Conqueror',           itemId = 18991, hasMagianPath = true  },
    [ 2] = { job = 'MNK', name = 'Glanzfaust',          itemId = 18992, hasMagianPath = true  },
    [ 3] = { job = 'WHM', name = 'Yagrush',             itemId = 18993, hasMagianPath = true  },
    [ 4] = { job = 'BLM', name = 'Laevateinn',          itemId = 18994, hasMagianPath = true  },
    [ 5] = { job = 'RDM', name = 'Murgleis',            itemId = 18995, hasMagianPath = true  },
    [ 6] = { job = 'THF', name = 'Vajra',               itemId = 18996, hasMagianPath = true  },
    [ 7] = { job = 'PLD', name = 'Burtgang',            itemId = 18997, hasMagianPath = true  },
    [ 8] = { job = 'DRK', name = 'Liberator',           itemId = 18998, hasMagianPath = true  },
    [ 9] = { job = 'BST', name = 'Aymur',               itemId = 18999, hasMagianPath = true  },
    [10] = { job = 'BRD', name = 'Carnwenhan',          itemId = 19000, hasMagianPath = true  },
    [11] = { job = 'RNG', name = 'Gastraphetes',        itemId = 19001, hasMagianPath = true  },
    [12] = { job = 'SAM', name = 'Kogarasumaru',        itemId = 19002, hasMagianPath = true  },
    [13] = { job = 'NIN', name = 'Nagi',                itemId = 19003, hasMagianPath = true  },
    [14] = { job = 'DRG', name = 'Ryunohige',           itemId = 19004, hasMagianPath = true  },
    [15] = { job = 'SMN', name = 'Nirvana',             itemId = 19005, hasMagianPath = true  },
    [16] = { job = 'BLU', name = 'Tizona',              itemId = 19006, hasMagianPath = true  },
    [17] = { job = 'COR', name = 'Death Penalty',       itemId = 19007, hasMagianPath = true  },
    [18] = { job = 'PUP', name = 'Kenkonken',           itemId = 19008, hasMagianPath = true  },
    [19] = { job = 'DNC', name = 'Terpsichore',         itemId = 18989, hasMagianPath = true  },
    [20] = { job = 'SCH', name = 'Tupsimati',           itemId = 18990, hasMagianPath = true  },
    [21] = { job = 'GEO', name = 'Idris (ilvl 119)',    itemId = 21080, hasMagianPath = false },
    [22] = { job = 'RUN', name = 'Epeolatry',           itemId = 20753, hasMagianPath = false },
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
    if entry.hasMagianPath then
        player:printToPlayer(string.format('%s (%s mythic, lv75) granted. Upgrade via Magian Moogles in Ru\'Lude Gardens.', entry.name, entry.job))
    else
        player:printToPlayer(string.format('%s granted (already at ilvl 119 — no further trial path needed).', entry.name))
    end

    return true
end
