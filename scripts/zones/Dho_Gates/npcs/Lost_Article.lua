-----------------------------------
-- Area: Dho Gates
--  NPC: Lost Article
-- Type: Coalition Assignment objective, Recover.
--
-- Client message 7412: "find an item that a pioneer lost".
-- All of the logic is in scripts/globals/coalition_assignments.lua; this file
-- only says which assignment family this entity closes.
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.coalitionAssignments.fieldNpc(player, xi.coalitionAssignments.kind.RECOVER)
end

return entity
