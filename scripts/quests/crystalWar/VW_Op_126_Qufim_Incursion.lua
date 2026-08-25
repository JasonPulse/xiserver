-----------------------------------
-- VW Op. 126: Qufim Incursion
-----------------------------------
-- Log ID: 7, Quest ID: 83
-- !addquest 7 83
-----------------------------------
-- Retail (bg-wiki "VW Op. 126: Qufim Incursion").
-- Step four of the Wings of the Goddess Voidwatch storyline, which runs from
-- Guardian of the Void (80) to Ad Infinitum (98) in quest-id order.
-- |Previous=Battle on a New Front  |Next=A Cait Calls
-- |Reward=50,000 gil
--   1. "Engage in and complete the 3 Tier III Voidwatch battles in the Qufim region."
--   2. "Speak with any Voidwatch Officer in PRESENT DAY to receive the Key Item
--      KI Voidwatch alarum."
--
-- Every notorious monster below was checked against sql/mob_spawn_points.sql and
-- sits in exactly the zone bg-wiki names for it.
--
-- The enum spells this VOIDWALKER_OP_126 rather than VW_OP_126, which is why a naive
-- title-to-enum lookup misses it.
--
-- The per-zone officer csid table, the refiner handling, and why the abyssite
-- upgrade is driven with printToPlayer rather than the refiner's own client-side
-- masked menu, are all documented in scripts/globals/voidwatch_wotg.lua.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.VOIDWALKER_OP_126)

-- Order matters: each entry's position is its bit in the kill mask.
local targets =
{
    { zone = xi.zone.QUFIM_ISLAND, mob = 'Kaggen' },
    { zone = xi.zone.LOWER_DELKFUTTS_TOWER, mob = 'Akvan' },
    { zone = xi.zone.BEHEMOTHS_DOMINION, mob = 'Pil' },
}

local targetCount = 3

--- The step is finished when every NM is down.
local stepIsDone = function(player)
    return xi.vwChain.allKilled(quest, player, targetCount)
end

local payOut = function(player, csid, option, npc)
    if quest:complete(player) then
        xi.vwChain.clearKills(quest, player)
        npcUtil.giveKeyItem(player, xi.ki.VOIDWATCH_ALARUM)
        npcUtil.giveCurrency(player, 'gil', 50000)
    end
end

local zones = xi.vwChain.killHandlers(quest, targets)

-- Any Voidwatch Officer reports the step in. The csid is looked up per zone because
-- every officer carries the same roles under different numbers.
for zoneId, _ in pairs(xi.vwChain.officers) do
    -- Resolved once, at build time: the handler is only registered for a zone that
    -- has an officer, so the closure captures a plain csid rather than looking it
    -- up again on every trigger.
    local officerCsid = xi.vwChain.officerCsid(zoneId, 'again')

    if officerCsid ~= nil then
        zones[zoneId] = zones[zoneId] or {}

        zones[zoneId]['Voidwatch_Officer'] =
        {
            onTrigger = function(player, npc)
                if not stepIsDone(player) then
                    return
                end

                return quest:progressEvent(officerCsid)
            end,
        }

        zones[zoneId].onEventFinish =
        {
            [officerCsid] = payOut,
        }
    end
end

local acceptedSection =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,
}

-- Assembled above rather than written inline: the target list drives which zones
-- appear, so writing them out by hand would duplicate the table.
for zoneId, handlers in pairs(zones) do
    acceptedSection[zoneId] = handlers
end

quest.sections = { acceptedSection }

return quest
