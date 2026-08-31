-----------------------------------
-- Area: Foret de Hennetiel
--  NPC: Station Administrator
-- Type: Coalition Assignment objective, Deliver.
--
-- Client message 7392: "bring supplies from the frontier station".
-- All of the logic is in scripts/globals/coalition_assignments.lua; this file
-- only says which assignment family this entity closes.
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.coalitionAssignments.fieldNpc(player, xi.coalitionAssignments.kind.DELIVER)
end

return entity
