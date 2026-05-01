-----------------------------------
-- Clash of the Comrades
-----------------------------------
-- Log ID: 3, Quest ID: 101
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Retail raised fellow lvlcap to 70 — dropped (no fellow API binding).
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.CLASH_OF_THE_COMRADES)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.MIXED_SIGNALS)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10043)
                end,
            },

            onEventFinish =
            {
                [10043] = function(player, csid, option, npc)
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
