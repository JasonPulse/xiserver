-----------------------------------
-- Area: Windurst Waters
--  NPC: Door: Acolyte Hostel (x11)
-- Simple doors along the hostel corridor — open on click.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    npc:openDoor()
end

return entity
