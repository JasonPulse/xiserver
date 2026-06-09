-----------------------------------
-- Area: Foret de Hennetiel
--  NPC: Waypoint
-----------------------------------
-- Frontier Station : !pos 398.11 -2 279.11 262
-- Bivouac #1       : !pos 12.6 -2.4 342 262
-- Bivouac #2       : !pos 505 -2.25 -303.5 262
-- Bivouac #3       : !pos 103 -2.2 -92.3 262
-- Bivouac #4       : !pos -251.8 -2.37 -39.25 262
--
-- Also acts as a Wildskeeper Reive pop trigger via xi.popTrigger.tryPop.
-- Holding (or Pop_Selection-pinning) a Compass of Transference pops
-- Tchakka here.
-----------------------------------
require('scripts/globals/pop_trigger')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.waypoint.onTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if xi.popTrigger.tryPop(player) then
        return
    end

    xi.waypoint.onTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.waypoint.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.waypoint.onEventFinish(player, csid, option, npc)
end

return entity
