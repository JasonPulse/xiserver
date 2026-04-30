-----------------------------------
-- Area: Western Adoulin
--  NPC: Ceciliotte
-- Mog Garden seed vendor (Inventors 2nd Floor)
-- !pos 82 -0.150 -45 256
-----------------------------------
local ID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost = 270

entity.onTrigger = function(player, npc)
    player:startEvent(7594, 0, cost, 0, player:getCurrency('bayld'))
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7594 and option == 1 then
        if player:getCurrency('bayld') >= cost then
            if npcUtil.giveItem(player, xi.item.ARBORSCENT_SEED) then
                player:delCurrency('bayld', cost)
            end
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
