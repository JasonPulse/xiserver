-----------------------------------
-- Undying Flames
-----------------------------------
-- Log ID: 0, Quest ID: 26
-- Pagisalis (Northern San d'Oria)
-----------------------------------
local northernSandyID = zones[xi.zone.NORTHERN_SAN_DORIA]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.UNDYING_FLAMES)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 2
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Pagisalis'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(562)
                end,
            },

            onEventFinish =
            {
                [562] = function(player, csid, option, npc)
                    if option == 0 then
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

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Pagisalis'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(565)
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.LUMP_OF_BEESWAX, 2) and
                        trade:getItemCount() == 2
                    then
                        return quest:progressEvent(563)
                    end
                end,
            },

            onEventFinish =
            {
                [563] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(northernSandyID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.FRIARS_ROPE)
                        return
                    end

                    player:tradeComplete()
                    player:addTitle(xi.title.FAITH_LIKE_A_CANDLE)
                    player:addItem(xi.item.FRIARS_ROPE)
                    player:messageSpecial(northernSandyID.text.ITEM_OBTAINED, xi.item.FRIARS_ROPE)
                    player:addFame(xi.fameArea.SANDORIA, 30)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Pagisalis'] = quest:progressEvent(566),
        },
    },
}

return quest
