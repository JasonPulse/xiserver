-----------------------------------
-- Area: Cirdas Caverns
--  NPC: Augural Conveyor — Alluvion Skirmish entry point (Cirdas
--       Caverns [U] uses Leaf + Snow stone drops).
-- Entity 17883909 ; CSID 5500 verified via xidat.
-----------------------------------
require('scripts/globals/skirmish')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.skirmish.conveyorOnTrigger(player, npc, 'Cirdas')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventUpdate(player, csid, option, 'Cirdas')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventFinish(player, csid, option, 'Cirdas')
end

return entity
