-----------------------------------
-- Area: Mamool Ja Training Grounds
--  NPC: Door: Master
-- Simple door — opens on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
