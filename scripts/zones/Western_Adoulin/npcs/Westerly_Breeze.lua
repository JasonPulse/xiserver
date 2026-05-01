-----------------------------------
-- Area: Western Adoulin
--  NPC: Westerly Breeze
-- !pos 62 32 123 256
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if trade:getItemCount() ~= 1 or trade:getGil() ~= 0 then
        return
    end

    local item = trade:getItem(0)
    if not item then
        return
    end

    local itemId = item:getID()
    local ahCategory = item:getAHCat()

    if
        ahCategory >= xi.itemAHCategory.MEAT_EGGS and
        ahCategory <= xi.itemAHCategory.SWEETS and
        player:getCharVar('ATWTTB_Can_Trade_Gruel') == 1 and
        (itemId == 4489 or itemId == 4534)
    then
        if itemId == 4489 then
            player:startEvent(5068)
        elseif itemId == 4534 then
            player:startEvent(5068, 1)
        end
    end
end

entity.onTrigger = function(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 5068 then
        player:tradeComplete()

        local gilObtained = 19716
        if option == 1 then
            gilObtained = 39432
        end

        npcUtil.giveCurrency(player, 'gil', gilObtained)
        player:setCharVar('ATWTTB_Can_Trade_Gruel', 0)
    end
end

return entity
