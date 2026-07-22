-----------------------------------
-- Area: Foret de Hennetiel
--  NPC: Delivery Specialist
-- Type: Item Deliverer (opens the delivery/send box)
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:openSendBox()
end

return entity
