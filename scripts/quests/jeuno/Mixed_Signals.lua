-----------------------------------
-- Mixed Signals
-----------------------------------
-- Log ID: 3, Quest ID: 87
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Retail raised fellow lvlcap to 65 — dropped (no fellow API binding).
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.MIXED_SIGNALS)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.REGAINING_TRUST)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10042)
                end,
            },

            onEventFinish =
            {
                [10042] = function(player, csid, option, npc)
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
