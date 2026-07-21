-----------------------------------
-- Zone: Escha_RuAun (289)
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    xi.eschanHub.applyVorseals(player)

    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-0.371, -34.277, -466.98, 187)
    end

    -- Domain Invasion rotation check (rate-limited).
    xi.domainInvasion.checkRotation()

    return cs
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
