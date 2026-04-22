-----------------------------------
-- A Reputation in Ruins
-----------------------------------
-- Log ID: 3, Quest ID: 73
-- Migliorozz : Upper Jeuno (H-9), default event 10026
-- Retail: Pso'Xja Gargoyle mini-boss chain using Crystal Receptor KIs.
-- Simplified for 4-player server: accept → zone into Pso'Xja →
-- return to Migliorozz for 3500 gil. Gargoyle kills skipped.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.A_REPUTATION_IN_RUINS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
    gil      = 3500,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.DARKNESS_NAMED)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Migliorozz'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10027)
                end,
            },

            onEventFinish =
            {
                [10027] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PSOXJA] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Visited') == 0 then
                    quest:setVar(player, 'Visited', 1)
                end

                return -1
            end,
        },

        [xi.zone.UPPER_JEUNO] =
        {
            ['Migliorozz'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Visited') == 1 then
                        return quest:progressEvent(10028)
                    end
                end,
            },

            onEventFinish =
            {
                [10028] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
