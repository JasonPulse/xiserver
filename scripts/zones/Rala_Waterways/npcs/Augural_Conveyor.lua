-----------------------------------
-- Area: Rala Waterways
--  NPC: Augural Conveyor — Alluvion Skirmish entry point (Rala/Cirdas
--       Mistmaw bosses, Leaf + Snow stone drops).
-- Entity 17834295 ; CSID 5500 verified via xidat.
-----------------------------------
require('scripts/globals/skirmish')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.skirmish.conveyorOnTrigger(player, npc, 'Rala')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventUpdate(player, csid, option, 'Rala')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventFinish(player, csid, option, 'Rala')
end

return entity
