-----------------------------------
-- Area: Yorcia Weald
--  NPC: Bivouac#2 Administrator
-- Type: Coalition Assignment objective, Support.
--
-- Client message 7393: "bring supplies to the frontier bivouac".
-- All of the logic is in scripts/globals/coalition_assignments.lua; this file
-- only says which assignment family this entity closes.
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.coalitionAssignments.fieldNpc(player, xi.coalitionAssignments.kind.SUPPORT)
end

return entity
