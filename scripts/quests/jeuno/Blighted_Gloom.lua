-----------------------------------
-- Blighted Gloom
-----------------------------------
-- Log ID: 3, Quest ID: 81
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Adventuring Fellow bond-cap chain (3/5). Raises bondcap to 70.
-- Retail: kill Metallic Slime for Vitrallum KI. Simplified: accept →
-- immediate complete.
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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.PAST_REFLECTIONS) and
                player:getFellowValue('bond') >= 45
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
                        if quest:complete(player) then
                            player:setFellowValue('bondcap', 70)
                        end
                    end
                end,
            },
        },
    },
}

return quest
