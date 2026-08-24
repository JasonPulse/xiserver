-----------------------------------
-- Western Waypoints, Ho!
-----------------------------------
-- Log ID: 9, Quest ID: 50
-- Alienor : Western Adoulin, entity 17825972
-- Waypoints : Western Adoulin, entities 17825973 .. 17825981
-- !addquest 9 50
-----------------------------------
-- Retail (bg-wiki "Western Waypoints, Ho!").
-- |Start=Alienor, Western Adoulin  |Fame=Adoulin |FLevel=1
--   1. "Speak to Alienor outside of the Pioneers' Coalition."
--   2. "Attune your geomagnetron to all 9 Waypoints in Western Adoulin."
--   3. "Return to Alienor for your rewards to complete the quest."
--   "If you already have all the Waypoints talk to her again to complete the quest",
--   which is why the accepted section can close immediately on a player who attuned
--   everything before taking the quest.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Western Adoulin:
--   5011 -> "Another day, another distraction, adventurer! Would you like to learn
--           more about this splendiferous machine here?"              THE OFFER
--   5012 -> "Let me see that thing. Maybe I can tell you which waypoints remain."
--                                                                     the turn-in
--   5009 and 5010 are her ambient lines about waypoints and the Pioneers'
--   Coalition, not part of this quest.
--
-- The nine waypoints bg-wiki lists match the nine `Waypoint` entities npc_list places
-- in this zone exactly, so all nine are required rather than a subset.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.WESTERN_WAYPOINTS_HO)

local waypoints =
{
    17825973,
    17825974,
    17825975,
    17825976,
    17825977,
    17825978,
    17825979,
    17825980,
    17825981,
}

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

local function attunedAll(player)
    local full = bit.lshift(1, #waypoints) - 1

    return bit.band(quest:getVar(player, 'Attuned'), full) == full
end

--- Attuning at a waypoint. Returns nothing so the waypoint's own travel menu still
--- opens; this only records that the player stood at it.
local waypointActions =
{
    onTrigger = function(player, npc)
        for index, id in ipairs(waypoints) do
            if id == npc:getID() then
                quest:setVar(player, 'Attuned',
                    bit.bor(quest:getVar(player, 'Attuned'), bit.lshift(1, index - 1)))

                return
            end
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Waypoint'] = waypointActions,

            ['Alienor'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5011)
                end,
            },

            onEventFinish =
            {
                [5011] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Waypoint'] = waypointActions,

            ['Alienor'] =
            {
                onTrigger = function(player, npc)
                    if not attunedAll(player) then
                        return quest:event(5011)
                    end

                    return quest:progressEvent(5012)
                end,
            },

            onEventFinish =
            {
                [5012] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Attuned', 0)
                    end
                end,
            },
        },
    },
}

return quest
