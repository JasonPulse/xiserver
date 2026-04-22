-----------------------------------
-- Yet Another Trial in Tandem
-----------------------------------
-- Log ID: 3, Quest ID: 162
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Magian_Moogle : Ru'Lude Gardens
-- Fellow lvlcap chain. Raises fellow lvlcap to 85.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.YET_ANOTHER_TRIAL_IN_TANDEM)

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
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.A_TRIAL_IN_TANDEM_REDUX) and
                player:getFellowValue('level') >= 76
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10048)
                end,
            },

            onEventFinish =
            {
                [10048] = function(player, csid, option, npc)
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
                    return quest:progressEvent(10049)
                end,
            },

            onEventFinish =
            {
                [10049] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setFellowValue('lvlcap', 85)
                    end
                end,
            },
        },
    },
}

return quest
