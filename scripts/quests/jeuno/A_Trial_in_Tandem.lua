-----------------------------------
-- A Trial in Tandem
-----------------------------------
-- Log ID: 3, Quest ID: 160
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Magian_Moogle : Ru'Lude Gardens (verified in npc_list.sql)
-- Fellow lvlcap chain (1/5). Raises fellow lvlcap to 75.
-- Retail: kill 30 XP-granting mobs wearing Tandem Necklace with fellow.
-- Simplified for 4-player server: accept from Luto → speak to Magian
-- Moogle → complete, cap raised.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.A_TRIAL_IN_TANDEM)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.CLASH_OF_THE_COMRADES) and
                player:getFellowValue('level') >= 66
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10044)
                end,
            },

            onEventFinish =
            {
                [10044] = function(player, csid, option, npc)
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
                    return quest:progressEvent(10045)
                end,
            },

            onEventFinish =
            {
                [10045] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setFellowValue('lvlcap', 75)
                    end
                end,
            },
        },
    },
}

return quest
