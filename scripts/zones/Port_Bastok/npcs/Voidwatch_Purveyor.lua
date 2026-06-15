-----------------------------------
-- Area: Port Bastok
--  NPC: Voidwatch Purveyor
-- Entity 17744058 ; CSIDs 32718/32719/32720 (all sentinels — real
-- program lives in event#.dat, like the other sentinel-based NPCs).
-- Verified via xidat. Using 32718 as the trigger entry point.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    SHOP_MENU = 32718,
}

entity.onTrigger = function(player, npc)
    local points = player:getCP()
    printf('[VW_Purveyor_PortBastok] onTrigger: conquestPoints=%d', points)
    player:startEvent(csids.SHOP_MENU, 0, points, xi.voidwatch.PURVEYOR_ITEM_COST, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[VW_Purveyor_PortBastok] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[VW_Purveyor_PortBastok] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local quantity  = bit.band(bit.rshift(option, 8), 0xFF)
    printf('[VW_Purveyor_PortBastok]   parsed: sel=%d qty=%d', selection, quantity)
end

return entity
