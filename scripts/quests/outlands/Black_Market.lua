-----------------------------------
-- Black Market
-----------------------------------
-- Log ID: 5, Quest ID: 130
-- Muzaffar !pos 16.678 -2.044 -14.600 252
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.BLACK_MARKET)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.NORG] =
        {
            ['Muzaffar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(15)
                end,
            },

            onEventFinish =
            {
                [15] = function(player, csid, option, npc)
                    if option == 1 then
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

        [xi.zone.NORG] =
        {
            ['Muzaffar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(16)
                end,

                onTrade = function(player, npc, trade)
                    local count = trade:getItemCount()

                    if count == 4 and trade:hasItemQty(xi.item.NORTHERN_FUR, 4) then
                        return quest:progressEvent(17, xi.item.NORTHERN_FUR, xi.item.NORTHERN_FUR)
                    elseif count == 4 and trade:hasItemQty(xi.item.PIECE_OF_EASTERN_POTTERY, 4) then
                        return quest:progressEvent(18, xi.item.PIECE_OF_EASTERN_POTTERY, xi.item.PIECE_OF_EASTERN_POTTERY)
                    elseif count == 4 and trade:hasItemQty(xi.item.SOUTHERN_MUMMY, 4) then
                        return quest:progressEvent(19, xi.item.SOUTHERN_MUMMY, xi.item.SOUTHERN_MUMMY)
                    end
                end,
            },

            onEventFinish =
            {
                [17] = function(player, csid, option, npc)
                    player:tradeComplete()
                    npcUtil.giveCurrency(player, 'gil', 1500)
                    player:addFame(xi.fameArea.NORG, 40)
                    player:addTitle(xi.title.BLACK_MARKETEER)

                    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.BLACK_MARKET) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end
                end,

                [18] = function(player, csid, option, npc)
                    player:tradeComplete()
                    npcUtil.giveCurrency(player, 'gil', 2000)
                    player:addFame(xi.fameArea.NORG, 50)
                    player:addTitle(xi.title.BLACK_MARKETEER)

                    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.BLACK_MARKET) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end
                end,

                [19] = function(player, csid, option, npc)
                    player:tradeComplete()
                    npcUtil.giveCurrency(player, 'gil', 3000)
                    player:addFame(xi.fameArea.NORG, 80)
                    player:addTitle(xi.title.BLACK_MARKETEER)

                    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.BLACK_MARKET) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
