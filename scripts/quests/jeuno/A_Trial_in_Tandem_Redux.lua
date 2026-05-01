-----------------------------------
-- A Trial in Tandem Redux
-----------------------------------
-- Log ID: 3, Quest ID: 161
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Magian_Moogle : Ru'Lude Gardens
-- Fellow lvlcap chain. Retail raised fellow lvlcap to 80 — dropped (no fellow API binding).
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.A_TRIAL_IN_TANDEM_REDUX)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.A_TRIAL_IN_TANDEM)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10046)
                end,
            },

            onEventFinish =
            {
                [10046] = function(player, csid, option, npc)
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

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Magian_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10047)
                end,
            },

            onEventFinish =
            {
                [10047] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
