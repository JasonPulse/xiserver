-----------------------------------
-- Reap What You Sow
-----------------------------------
-- Log ID: 2, Quest ID: 29
-- Mashuu-Ajuu !pos 129 -6 167 238
-----------------------------------
local watersID = zones[xi.zone.WINDURST_WATERS]
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.REAP_WHAT_YOU_SOW)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Mashuu-Ajuu'] =
            {
                onTrigger = function(player, npc)
                    if math.random(1, 2) == 1 then
                        return quest:progressEvent(463, 0, xi.item.SOBBING_FUNGUS, xi.item.BAG_OF_HERB_SEEDS)
                    end
                end,
            },

            onEventFinish =
            {
                [463] = function(player, csid, option, npc)
                    if option == 3 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(watersID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.BAG_OF_HERB_SEEDS)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.BAG_OF_HERB_SEEDS)
                            player:messageSpecial(watersID.text.ITEM_OBTAINED, xi.item.BAG_OF_HERB_SEEDS)
                        end
                    end
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
            ['Mashuu-Ajuu'] =
            {
                onTrigger = function(player, npc)
                    if math.random(1, 2) == 1 then
                        return quest:progressEvent(464, 0, xi.item.SOBBING_FUNGUS, xi.item.BAG_OF_HERB_SEEDS)
                    else
                        return quest:progressEvent(476)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if trade:getItemCount() ~= 1 or trade:getGil() ~= 0 then
                        return
                    end

                    if trade:hasItemQty(xi.item.SOBBING_FUNGUS, 1) then
                        return quest:progressEvent(475, 500, xi.item.STATIONERY_SET)
                    elseif trade:hasItemQty(xi.item.DEATHBALL, 1) then
                        return quest:progressEvent(477, 700)
                    end
                end,
            },

            onEventFinish =
            {
                [475] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(watersID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.STATIONERY_SET)
                        return
                    end

                    player:addGil(xi.settings.main.GIL_RATE * 500)
                    player:tradeComplete()
                    quest:setMustZone(player)

                    if quest:complete(player) then
                        player:addFame(xi.fameArea.WINDURST, 75)
                        player:addItem(xi.item.STATIONERY_SET)
                        player:messageSpecial(watersID.text.ITEM_OBTAINED, xi.item.STATIONERY_SET)
                    end
                end,

                [477] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(watersID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.STATIONERY_SET)
                        return
                    end

                    player:addGil(xi.settings.main.GIL_RATE * 700)
                    player:tradeComplete()
                    quest:setMustZone(player)

                    if quest:complete(player) then
                        player:addFame(xi.fameArea.WINDURST, 75)
                        player:addItem(xi.item.STATIONERY_SET)
                        player:messageSpecial(watersID.text.ITEM_OBTAINED, xi.item.STATIONERY_SET)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Mashuu-Ajuu'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(478)
                    elseif quest:getVar(player, 'Repeat') == 0 then
                        if math.random(1, 2) == 1 then
                            return quest:progressEvent(479, 0, xi.item.SOBBING_FUNGUS, xi.item.BAG_OF_HERB_SEEDS)
                        end
                    elseif math.random(1, 2) == 1 then
                        return quest:progressEvent(464, 0, xi.item.SOBBING_FUNGUS, xi.item.BAG_OF_HERB_SEEDS)
                    else
                        return quest:progressEvent(476)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Repeat') ~= 1 or
                        trade:getItemCount() ~= 1 or
                        trade:getGil() ~= 0
                    then
                        return
                    end

                    if trade:hasItemQty(xi.item.SOBBING_FUNGUS, 1) then
                        return quest:progressEvent(475, 500)
                    elseif trade:hasItemQty(xi.item.DEATHBALL, 1) then
                        return quest:progressEvent(477, 700)
                    end
                end,
            },

            onEventFinish =
            {
                [479] = function(player, csid, option, npc)
                    if option == 3 then
                        quest:setVar(player, 'Repeat', 1)
                        player:addItem(xi.item.BAG_OF_HERB_SEEDS)
                        player:messageSpecial(watersID.text.ITEM_OBTAINED, xi.item.BAG_OF_HERB_SEEDS)
                    end
                end,

                [475] = function(player, csid, option, npc)
                    player:addGil(xi.settings.main.GIL_RATE * 500)
                    player:tradeComplete()
                    player:addFame(xi.fameArea.WINDURST, 8)
                    quest:setVar(player, 'Repeat', 0)
                end,

                [477] = function(player, csid, option, npc)
                    player:addGil(xi.settings.main.GIL_RATE * 700)
                    player:tradeComplete()
                    player:addFame(xi.fameArea.WINDURST, 8)
                    quest:setVar(player, 'Repeat', 0)
                end,
            },
        },
    },
}

return quest
