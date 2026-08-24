-----------------------------------
-- A Farewell to Felines
-----------------------------------
-- Log ID: 7, Quest ID: 91
-- !addquest 7 91
-----------------------------------
-- Retail (bg-wiki "A Farewell to Felines").
-- Step twelve of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=Between a Rock and Rift  |Next=Third Tour of Duchy
-- |Reward=KI Voidwatch alarum
--   "Speak with any Voidwatch Officer to receive a Voidwatch alarum. You must wait
--    until the Vana'diel day changes over to 0:00 after completing Between a Rock and
--    Rift to receive the Voidwatch alarum."
--
-- ERA MATTERS HERE, and it is the only thing that distinguishes this step from the
-- other alarum steps: bg-wiki places no era restriction on this one, so every
-- officer qualifies. What it DOES gate on is the Vana'diel day rolling over since
-- the previous step, which is checked below.
-- Every Voidwatch Officer carries the same nine event blocks under different csid
-- numbers per zone, so the officer table in scripts/globals/voidwatch_wotg.lua is
-- keyed by zone and the block is selected by role rather than by a hardcoded number.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_FAREWELL_TO_FELINES)

--- Officers of the era this step accepts.
local eligibleZone = function(zoneId)
    return xi.vwChain.officers[zoneId] ~= nil
end

local giveAlarum = function(player, csid, option, npc)
    if quest:complete(player) then
        npcUtil.giveKeyItem(player, xi.ki.VOIDWATCH_ALARUM)
    end
end

local zones = {}

for zoneId, _ in pairs(xi.vwChain.officers) do
    if eligibleZone(zoneId) then
        zones[zoneId] =
        {
            ['Voidwatch_Officer'] =
            {
                onTrigger = function(player, npc)
                    -- "You must wait until the Vana'diel day changes over to 0:00
                    -- after completing Between a Rock and Rift."
                    if quest:getVar(player, 'Day') >= VanadielUniqueDay() then
                        return
                    end

                    return quest:progressEvent(xi.vwChain.officerCsid(player:getZoneID(), 'again'))
                end,
            },

            onEventFinish =
            {
                [xi.vwChain.officerCsid(zoneId, 'again')] = giveAlarum,
            },
        }
    end
end

local acceptedSection =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,
}

for zoneId, handlers in pairs(zones) do
    acceptedSection[zoneId] = handlers
end

quest.sections = { acceptedSection }

return quest
