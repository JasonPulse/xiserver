-----------------------------------
-- Area: Western Adoulin
--  NPC: Door: Svenjas Manor
-- Simple door — opens on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
