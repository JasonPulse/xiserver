-----------------------------------
-- Legendary Plan B
-----------------------------------
-- Log ID: 2, Quest ID: 44
-- Kopuro-Popuro !pos -0.037 -4.749 -22.589 241
-- Kororo        !pos -11.883 -3.75 5.508 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.LEGENDARY_PLAN_B)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    item     = xi.item.SCENTLESS_ARMLETS,
    gil      = 700,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.A_GREETING_CARDIAN) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.WINDURST) >= 3
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    if player:needToZone() then
                        return quest:progressEvent(306)
                    else
                        return quest:progressEvent(308, 0, 529, 940, 858)
                    end
                end,
            },

            onEventFinish =
            {
                [308] = function(player, csid, option, npc)
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
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(309, 0, 529, 940, 858)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 529, 858, 940 }) then
                        return quest:progressEvent(314, 0, 529, 940, 858)
                    else
                        return quest:progressEvent(309, 0, 529, 940, 858)
                    end
                end,
            },

            ['Kororo'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(312, 0, 529, 940, 858)
                end,
            },

            onEventFinish =
            {
                [314] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                        player:needToZone(true)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] = quest:event(316),
        },
    },
}

return quest
