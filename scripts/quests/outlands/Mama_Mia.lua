-----------------------------------
-- Mama Mia
-----------------------------------
-- Log ID: 5, Quest ID: 131
-- Mamaulabion !pos -57 -9 68 252
-----------------------------------
local norgID = zones[xi.zone.NORG]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.MAMA_MIA)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.NORG) >= 4 and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.THE_MOONLIT_PATH) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Mamaulabion'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(191)
                end,
            },

            onEventFinish =
            {
                [191] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Mamaulabion'] =
            {
                onTrigger = function(player, npc)
                    local tradesMamaMia = player:getCharVar('tradesMamaMia')

                    if utils.mask.isFull(tradesMamaMia, 7) then
                        if GetSystemTime() < player:getCharVar('MamaMia_date') then
                            return quest:progressEvent(196)
                        else
                            return quest:progressEvent(197)
                        end
                    else
                        return quest:progressEvent(192)
                    end
                end,

                onTrade = function(player, npc, trade)
                    for i = xi.item.BOTTLE_OF_BUBBLY_WATER, xi.item.ANCIENTS_KEY do
                        if npcUtil.tradeHasExactly(trade, i) then
                            local mask = player:getCharVar('tradesMamaMia')
                            local bit = i - xi.item.BOTTLE_OF_BUBBLY_WATER

                            if utils.mask.getBit(mask, bit) then
                                return quest:progressEvent(194)
                            end

                            mask = utils.mask.setBit(mask, bit, true)
                            player:setCharVar('tradesMamaMia', mask)

                            if utils.mask.isFull(mask, 7) then
                                return quest:progressEvent(195)
                            else
                                return quest:progressEvent(193)
                            end
                        end
                    end
                end,
            },

            onEventFinish =
            {
                [193] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,

                [195] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:setCharVar('MamaMia_date', JstMidnight())
                end,

                [197] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(norgID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.EVOKERS_RING)
                        return
                    end

                    player:addItem(xi.item.EVOKERS_RING)
                    player:messageSpecial(norgID.text.ITEM_OBTAINED, xi.item.EVOKERS_RING)
                    player:addFame(xi.fameArea.NORG, 30)
                    quest:complete(player)
                    player:setCharVar('tradesMamaMia', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Mamaulabion'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.EVOKERS_RING) then
                        return quest:progressEvent(198)
                    else
                        return quest:progressEvent(243)
                    end
                end,
            },

            onEventFinish =
            {
                [243] = function(player, csid, option, npc)
                    if option == 1 then
                        player:delQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.MAMA_MIA)
                        quest:begin(player)
                    end
                end,
            },
        },
    },
}

return quest
