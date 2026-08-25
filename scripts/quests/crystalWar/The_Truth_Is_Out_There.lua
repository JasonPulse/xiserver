-----------------------------------
-- The Truth Is Out There
-----------------------------------
-- Log ID: 7, Quest ID: 85
-- !addquest 7 85
-----------------------------------
-- Retail (bg-wiki "The Truth Is Out There").
-- Step six of the Wings of the Goddess Voidwatch storyline (80..98, in id order).
-- |Previous=A Cait Calls  |Next=Re-Drafted by the Duchy
-- |Reward=KI Voidwatch alarum
--   "Speak to any present-day Voidwatch Officer to receive the key item Voidwatch
--    alarum. Receiving the item ends this quest and begins the next."
--
-- ERA MATTERS HERE, and it is the only thing that distinguishes this step from the
-- other alarum steps: bg-wiki says any PRESENT-DAY officer, so the Shadowreign
-- ones are excluded.
-- Every Voidwatch Officer carries the same nine event blocks under different csid
-- numbers per zone, so the officer table in scripts/globals/voidwatch_wotg.lua is
-- keyed by zone and the block is selected by role rather than by a hardcoded number.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_TRUTH_IS_OUT_THERE)

--- Officers of the era this step accepts.
local eligibleZone = function(zoneId)
    return not xi.vwChain.shadowreign[zoneId]
end

local giveAlarum = function(player, csid, option, npc)
    if quest:complete(player) then
        npcUtil.giveKeyItem(player, xi.ki.VOIDWATCH_ALARUM)
    end
end

local zones = {}

for zoneId, _ in pairs(xi.vwChain.officers) do
    local officerCsid = xi.vwChain.officerCsid(zoneId, 'again')

    if eligibleZone(zoneId) and officerCsid ~= nil then
        zones[zoneId] =
        {
            ['Voidwatch_Officer'] =
            {
                onTrigger = function(player, npc)
                    -- No further gate: bg-wiki asks only that the officer be present day.
                    return quest:progressEvent(officerCsid)
                end,
            },

            onEventFinish =
            {
                [officerCsid] = giveAlarum,
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
