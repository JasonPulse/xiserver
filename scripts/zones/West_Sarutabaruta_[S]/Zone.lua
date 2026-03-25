-----------------------------------
-- Zone: West_Sarutabaruta_[S] (95)
-----------------------------------
---@type TZone
local zoneObject = {}

-- Map Server Main Game Loop Behind Due to server_variables
-- aka: Dark Ixion Chatty hammer "fix"

-- We are Commenting out these two lines for now to help reduce map server main game loop warnings & errors.
    --xi.darkixion.zoneOnInit(zone)
    --xi.darkixion.zoneOnGameHour(zone)

-- Dark Ixion code fires off "Every ~2 minutes earth time" to accesses the `xidb`.`server_variables` table and writes to it an updated "pop time".

-- This is extremely chatty and taxing when run on "value" server hardware.
-- In addition, does it really need to update every 2 minutes that he's still there,
-- it's not like he's supposed to re-zone every in game hour.

-- Best we can tell, the zoneOnGameHour along with the scripts\globals\dark_ixion.lua xi.darkixion.repop() function
-- is what allows Dark Ixion
--   To break the rule of "no loading zones and mobs if there are no players in them"
--   Keeps him constnatly updating the Database `xidb`.`server_variables` table

zoneObject.onInitialize = function(zone)
    xi.helm.initZone(zone, xi.helmType.HARVESTING)
    xi.voidwalker.zoneOnInit(zone)
    --xi.darkixion.zoneOnInit(zone)
end

zoneObject.onGameHour = function(zone)
    --xi.darkixion.zoneOnGameHour(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(320.018, -6.684, -45.166, 189)
    end

    return cs
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
