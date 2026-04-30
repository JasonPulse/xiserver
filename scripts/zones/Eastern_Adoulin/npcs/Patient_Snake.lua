-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Patient Snake
-- Sells Celennia Memorial Library Card for 1000 bayld (F-9, Scouts)
-- !pos -112 -0.650 -60 257
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cardCost = 1000

entity.onTrigger = function(player, npc)
    local bayld = player:getCurrency('bayld')

    if player:hasKeyItem(xi.ki.CELENNIA_MEMORIAL_LIBRARY_CARD) then
        player:startEvent(7591, 0, 0, 0, bayld)
    else
        player:startEvent(7535, cardCost, 0, 0, bayld)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7535 and option == 1 then
        if player:getCurrency('bayld') >= cardCost then
            player:delCurrency('bayld', cardCost)
            npcUtil.giveKeyItem(player, xi.ki.CELENNIA_MEMORIAL_LIBRARY_CARD)
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
