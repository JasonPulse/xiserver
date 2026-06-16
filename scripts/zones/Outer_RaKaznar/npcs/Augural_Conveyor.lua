-----------------------------------
-- Area: Outer Ra'Kaznar
--  NPC: Augural Conveyor — Alluvion Skirmish entry point (Outer
--       Ra'Kaznar [U] uses Snow + Dusk stone drops).
-- Entity 17900002 ; CSID 5500 verified via xidat.
-----------------------------------
require('scripts/globals/skirmish')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.skirmish.conveyorOnTrigger(player, npc, 'OuterRaKaz')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventUpdate(player, csid, option, 'OuterRaKaz')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventFinish(player, csid, option, 'OuterRaKaz')
end

return entity
