-----------------------------------
-- Zone: Yorcia Weald
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.reives.setupZone(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(254, 6, 64, 219)
    end

    -- Domain Invasion rotation check. Internally rate-limited so multiple
    -- zone-ins don't double-spawn.
    xi.domainInvasion.checkRotation()

    return cs
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
