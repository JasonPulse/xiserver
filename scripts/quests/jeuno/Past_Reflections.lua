-----------------------------------
-- Past Reflections
-----------------------------------
-- Log ID: 3, Quest ID: 80
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (2/5). Raises bondcap to 50.
-- Simplified for 4-player server: accept → immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.PAST_REFLECTIONS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.GIRL_IN_THE_LOOKING_GLASS)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10038)
                end,
            },

            onEventFinish =
            {
                [10038] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        if quest:complete(player) then
                            player:setFellowValue('bondcap', 50)
                        end
                    end
                end,
            },
        },
    },
}

return quest
