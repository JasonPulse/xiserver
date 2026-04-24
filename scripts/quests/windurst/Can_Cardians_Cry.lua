-----------------------------------
-- Can Cardians Cry?
-----------------------------------
-- Log ID: 2, Quest ID: 47
-- Apururu !pos -11 -2 13 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.CAN_CARDIANS_CRY)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    gil      = 5000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.THE_ALL_NEW_C_3000) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.WINDURST) >= 5
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Apururu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(319, 0, 20000)
                end,
            },

            onEventFinish =
            {
                [319] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Apururu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(320, 0, 20000)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, xi.item.BRUISED_STARFRUIT) then
                        return quest:progressEvent(325, 0, 20000, 5000)
                    end
                end,
            },

            onEventFinish =
            {
                [325] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
