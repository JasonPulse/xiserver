-----------------------------------
-- Hoist the Jelly, Roger
-----------------------------------
-- Log ID: 2, Quest ID: 51
-- Maysoon !pos -105 -2 69 238
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.HOIST_THE_JELLY_ROGER)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    keyItem  = xi.ki.SUPER_SOUP_POT,
    fame     = 30,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.COOKS_PRIDE) == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Maysoon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10000)
                end,
            },

            onEventFinish =
            {
                [10000] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Maysoon'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.SERVING_OF_ROYAL_JELLY, 1) and
                        trade:getGil() == 0 and
                        trade:getItemCount() == 1
                    then
                        return quest:progressEvent(10001)
                    end
                end,
            },

            onEventFinish =
            {
                [10001] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:tradeComplete()
                    end
                end,
            },
        },
    },
}

return quest
