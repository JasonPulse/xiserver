-----------------------------------
-- Blighted Gloom
-----------------------------------
-- Log ID: 3, Quest ID: 81
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (3/5). Retail bondcap 70 reward
-- dropped — server has no fellow API binding. Quest still completes.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.BLIGHTED_GLOOM)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PAST_REFLECTIONS)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10039)
                end,
            },

            onEventFinish =
            {
                [10039] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
