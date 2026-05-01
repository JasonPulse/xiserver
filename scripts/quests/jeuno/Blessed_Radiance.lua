-----------------------------------
-- Blessed Radiance
-----------------------------------
-- Log ID: 3, Quest ID: 82
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (4/5). Retail bondcap 90 reward
-- dropped — server has no fellow API binding. Quest still completes.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.BLESSED_RADIANCE)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.BLIGHTED_GLOOM)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10040)
                end,
            },

            onEventFinish =
            {
                [10040] = function(player, csid, option, npc)
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
