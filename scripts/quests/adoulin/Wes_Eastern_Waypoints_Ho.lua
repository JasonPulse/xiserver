-----------------------------------
-- Wes...Eastern Waypoints, Ho!
-----------------------------------
-- Log ID: 9, Quest ID: 51
-- Sharuru : Eastern Adoulin, entity 17830011
-- Waypoints : Eastern Adoulin, entities 17830015 .. 17830023
-- !addquest 9 51
-----------------------------------
-- Retail (bg-wiki "Wes...Eastern Waypoints, Ho!").
-- |Start=Sharuru, Eastern Adoulin  |Fame=Adoulin |FLevel=1
--   1. "Speak to Sharuru outside of the Peacekeepers' Coalition."
--   2. "Attune your geomagnetron to all 9 Waypoints in Eastern Adoulin."
--   3. "Return to Sharuru for your rewards to complete the quest."
--   "If you already have all the Waypoints talk to her again to complete the quest",
--   which is why the accepted section can close immediately on a player who attuned
--   everything before taking the quest.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Eastern Adoulin:
--   5011 -> the offer. Her programme mirrors Alienor's: event lookup is zone
--           global, so 5011 and 5012 in Eastern Adoulin are Sharuru's copies of
--           the same pair, not Alienor's.
--   5012 -> the turn-in.
--
-- The nine waypoints bg-wiki lists match the nine `Waypoint` entities npc_list places
-- in this zone exactly, so all nine are required rather than a subset.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.WESEASTERN_WAYPOINTS_HO)

local waypoints =
{
    17830015,
    17830016,
    17830017,
    17830018,
    17830019,
    17830020,
    17830021,
    17830022,
    17830023,
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

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Waypoint'] = waypointActions,

            ['Sharuru'] =
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

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Waypoint'] = waypointActions,

            ['Sharuru'] =
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
