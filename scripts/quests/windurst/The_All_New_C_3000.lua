-----------------------------------
-- The All-New C-3000
-----------------------------------
-- Log ID: 2, Quest ID: 18
-- Kopuro-Popuro !pos -0.037 -4.749 -22.589 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.THE_ALL_NEW_C_3000)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 10,
    gil      = 600,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.LEGENDARY_PLAN_B) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.WINDURST) >= 4
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    if player:needToZone() then
                        return quest:progressEvent(316)
                    else
                        return quest:progressEvent(655, 0, 889, 939)
                    end
                end,
            },

            onEventFinish =
            {
                [655] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(659, 0, 889, 939)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 889, 939 }) then
                        return quest:progressEvent(657, 0, 889, 939)
                    else
                        return quest:progressEvent(656, 0, 889, 939)
                    end
                end,
            },

            onEventFinish =
            {
                [657] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
