-----------------------------------
-- Area: Lower Jeuno
--  NPC: Voidwatch Purveyor
-- Entity 17780980 ; CSID 10109(2400b) verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    SHOP_MENU = 10109,
}

entity.onTrigger = function(player, npc)
    local points = player:getCP()
    printf('[VW_Purveyor_LowerJeuno] onTrigger: conquestPoints=%d', points)
    player:startEvent(csids.SHOP_MENU, 0, points, xi.voidwatch.PURVEYOR_ITEM_COST, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[VW_Purveyor_LowerJeuno] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[VW_Purveyor_LowerJeuno] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local quantity  = bit.band(bit.rshift(option, 8), 0xFF)
    printf('[VW_Purveyor_LowerJeuno]   parsed: sel=%d qty=%d', selection, quantity)
end

return entity
