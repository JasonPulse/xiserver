-----------------------------------
-- Mirror Images
-----------------------------------
-- Log ID: 3, Quest ID: 83
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (5/5). Retail bondcap 120 reward
-- dropped — server has no fellow API binding. Quest still completes.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.MIRROR_IMAGES)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.BLESSED_RADIANCE) and
                player:getMainLvl() >= 50
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10041)
                end,
            },

            onEventFinish =
            {
                [10041] = function(player, csid, option, npc)
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
