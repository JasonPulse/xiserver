-----------------------------------
-- Zone: Ruhotz_Silvermines
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
end

zoneObject.onInstanceZoneIn = function(player, instance)
    if player:getInstance() == nil then
        player:setPos(0, 0, 0, 0, 90)
        return
    end

    local pos = player:getPos()
    if pos.x == 0 and pos.y == 0 and pos.z == 0 then
        local entrypos = instance:getEntryPos()
        player:setPos(entrypos.x, entrypos.y, entrypos.z, entrypos.rot)
    end
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
    -- csid 10000 is the generic "instance cleared" event and is reused by every
    -- instance in this zone, but this exit is light_in_the_darkness's specifically
    -- (instance_list 9300 -> exit zone 90; fire_in_the_hole 9301 exits to 88).
    -- Unguarded it dumped anyone clearing any Ruhotz instance into Pashhow.
    if csid == 10000 then
        local instance = player:getInstance()

        if instance and instance:getName() == 'light_in_the_darkness' then
            player:setPos(-385.602, 21.970, 456.359, 0, 90)
        end
    end
end

zoneObject.onInstanceLoadFailed = function()
    -- NOTE: This instance has several connection points, and once
    -- utilized should send the the appropriate area on load fail.
end

return zoneObject
