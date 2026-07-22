-----------------------------------
-- Area: North Gustaberg
--  NPC: Geomagnetic Fount
-- SoA mission attunement (The Geomagnetron) + proto-waypoint travel
-- destination: click once on foot to attune, then travel here from any
-- proto-waypoint (see scripts/globals/teleports/proto_waypoint.lua).
-----------------------------------
require('scripts/globals/teleports/proto_waypoint')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.protoWaypoint.fountOnTrigger(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
