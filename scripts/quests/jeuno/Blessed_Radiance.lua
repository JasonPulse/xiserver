-----------------------------------
-- Blessed Radiance
-----------------------------------
-- Log ID: 3, Quest ID: 82
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (4/5). Raises bondcap to 90.
-- Retail: gather Mistroot/Lunascent Log/Glimmering Mica with fellow,
-- scry at Beaucedine Mirror Pond. Simplified: accept → immediate complete.
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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.BLIGHTED_GLOOM) and
                player:getFellowValue('bond') >= 70
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
                        if quest:complete(player) then
                            player:setFellowValue('bondcap', 90)
                        end
                    end
                end,
            },
        },
    },
}

return quest
