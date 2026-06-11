-----------------------------------
-- Area: Mog Garden (280)
--  NPC: Coastal Fishing Net
-- Gathering node — see scripts/globals/mog_garden.lua nodeFamilies.
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.mog_garden.nodeOnTrigger(player, npc)
end

return entity
