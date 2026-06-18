-----------------------------------
-- Zone: Dynamis-Qufim
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.dynamis.zoneOnInitialize(zone)
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onZoneIn = function(player, prevZone)
    -- Domain Invasion rotation check (rate-limited).
    xi.domainInvasion.checkRotation()

    return xi.dynamis.zoneOnZoneIn(player, prevZone)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
    xi.dynamis.zoneOnEventFinish(player, csid, option, npc)
end

return zoneObject
