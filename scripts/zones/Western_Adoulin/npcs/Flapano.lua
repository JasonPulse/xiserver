-----------------------------------
-- Area: Western Adoulin
--  NPC: Flapno
-- !pos 70 0 -13 256
-----------------------------------
local ID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if
        player:hasKeyItem(xi.ki.TARUTARU_SAUCE_INVOICE) and
        npcUtil.tradeHas(trade, { { 'gil', 5600 } })
    then
        local paidFlapano = utils.mask.getBit(player:getCharVar('ATWTTB_Payments'), 2)
        if not paidFlapano then
            player:startEvent(5071)
        end
    end
end

entity.onTrigger = function(player, npc)
    local theWeatherspoonWar = player:getQuestStatus(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_WEATHERSPOON_WAR)

    if
        theWeatherspoonWar == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('Weatherspoon_War_Status') == 6
    then
        player:startEvent(191)
    else
        player:showText(npc, ID.text.FLAPANO_SHOP_TEXT)

        local stock =
        {
            { 5943,   125, },
            { 4415,   124, },
            { 4434,  5000, },
            { 5145,  5600, },
            { 4423,   300, },
            { 4405,   160, },
            { 5676, 76475, },
        }

        xi.shop.general(player, stock)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 5071 then
        player:confirmTrade()
        player:setCharVar('ATWTTB_Payments', utils.mask.setBit(player:getCharVar('ATWTTB_Payments'), 2, true))

        if utils.mask.isFull(player:getCharVar('ATWTTB_Payments'), 5) then
            npcUtil.giveKeyItem(player, xi.ki.TARUTARU_SAUCE_RECEIPT)
        end
    end
end

return entity
