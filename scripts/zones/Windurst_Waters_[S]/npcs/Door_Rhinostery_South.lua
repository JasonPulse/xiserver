-----------------------------------
-- Area: Windurst Waters (S)
--  NPC: Door: Rhinostery South
-- Simple door — opens on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
