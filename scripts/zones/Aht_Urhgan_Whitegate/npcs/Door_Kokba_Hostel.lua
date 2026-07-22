-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Door: Kokba Hostel
-- Simple door — opens on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
