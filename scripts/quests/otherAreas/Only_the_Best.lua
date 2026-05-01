-----------------------------------
-- Only the Best
-----------------------------------
-- Log ID: 4, Quest ID: 18
-- Melyon !pos 25 -6 6 248
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ONLY_THE_BEST)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.SELBINA] =
        {
            ['Melyon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(60, 4366, 629, xi.item.CLUMP_OF_BOYAHDA_MOSS)
                end,
            },

            onEventFinish =
            {
                [60] = function(player, csid, option, npc)
                    if option == 10 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SELBINA] =
        {
            ['Melyon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(61, 4366, 629, xi.item.CLUMP_OF_BOYAHDA_MOSS)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { 4366, 5 } }) then
                        return quest:progressEvent(62, 0, 4366)
                    elseif npcUtil.tradeHas(trade, { { 629, 3 } }) then
                        return quest:progressEvent(63, 0, 629)
                    elseif npcUtil.tradeHas(trade, xi.item.CLUMP_OF_BOYAHDA_MOSS) then
                        return quest:progressEvent(64, 0, xi.item.CLUMP_OF_BOYAHDA_MOSS)
                    end
                end,
            },

            onEventFinish =
            {
                [62] = function(player, csid, option, npc)
                    if option == 11 then
                        npcUtil.giveCurrency(player, 'gil', 100)
                        player:addFame(xi.fameArea.BASTOK, 10)
                        player:addFame(xi.fameArea.SANDORIA, 10)
                        player:addFame(xi.fameArea.JEUNO, 10)

                        if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ONLY_THE_BEST) == xi.questStatus.QUEST_ACCEPTED then
                            quest:complete(player)
                        end

                        player:confirmTrade()
                    end
                end,

                [63] = function(player, csid, option, npc)
                    if option == 12 then
                        npcUtil.giveCurrency(player, 'gil', 120)
                        player:addFame(xi.fameArea.BASTOK, 20)
                        player:addFame(xi.fameArea.SANDORIA, 20)
                        player:addFame(xi.fameArea.JEUNO, 20)

                        if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ONLY_THE_BEST) == xi.questStatus.QUEST_ACCEPTED then
                            quest:complete(player)
                        end

                        player:confirmTrade()
                    end
                end,

                [64] = function(player, csid, option, npc)
                    if option == 13 then
                        npcUtil.giveCurrency(player, 'gil', 600)
                        player:addFame(xi.fameArea.BASTOK, 30)
                        player:addFame(xi.fameArea.SANDORIA, 30)
                        player:addFame(xi.fameArea.JEUNO, 30)

                        if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ONLY_THE_BEST) == xi.questStatus.QUEST_ACCEPTED then
                            quest:complete(player)
                        end

                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
