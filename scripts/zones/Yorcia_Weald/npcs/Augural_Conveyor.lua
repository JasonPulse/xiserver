-----------------------------------
-- Area: Yorcia Weald
--  NPC: Augural Conveyor — Alluvion Skirmish entry point (Yorcia
--       Weald [U] uses Leaf + Dusk stone drops).
-- Entity 17855007 ; CSID 5500 verified via xidat.
-----------------------------------
require('scripts/globals/skirmish')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.skirmish.conveyorOnTrigger(player, npc, 'Yorcia')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventUpdate(player, csid, option, 'Yorcia')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.skirmish.conveyorOnEventFinish(player, csid, option, 'Yorcia')
end

return entity
