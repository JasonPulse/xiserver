-----------------------------------
-- Area: Norg
--  NPC: Proto-Waypoint
-- Town proto-waypoint network (see scripts/globals/teleports/proto_waypoint.lua).
-----------------------------------
require('scripts/globals/teleports/proto_waypoint')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.protoWaypoint.onTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.protoWaypoint.onEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.protoWaypoint.onEventFinish(player, csid, option, npc)
end

return entity
