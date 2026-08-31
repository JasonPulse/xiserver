-----------------------------------
-- Area: Yorcia Weald
--  NPC: Ergon Locus 2
-- Type: Coalition Assignment objective, Survey.
--
-- Client message 7399: "survey an ergon locus".
-- All of the logic is in scripts/globals/coalition_assignments.lua; this file
-- only says which assignment family this entity closes.
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.coalitionAssignments.fieldNpc(player, xi.coalitionAssignments.kind.SURVEY)
end

return entity
