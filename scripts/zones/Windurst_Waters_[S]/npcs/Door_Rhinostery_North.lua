-----------------------------------
-- Area: Windurst Waters (S)
--  NPC: Door: Rhinostery North
-- Simple door — opens on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
