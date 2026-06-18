-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Voidwatch Purveyor
-- Entity 16982636 ; CSID 968(2400b) verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    SHOP_MENU = 968,
}

entity.onTrigger = function(player, npc)
    -- Whitegate uses Imperial Standing, not Conquest Points.
    local points = player:getCurrency('imperial_standing')
    printf('[VW_Purveyor_Whitegate] onTrigger: imperialStanding=%d', points)
    player:startEvent(csids.SHOP_MENU, 0, points, xi.voidwatch.PURVEYOR_ITEM_COST, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[VW_Purveyor_Whitegate] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[VW_Purveyor_Whitegate] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local quantity  = bit.band(bit.rshift(option, 8), 0xFF)
    printf('[VW_Purveyor_Whitegate]   parsed: sel=%d qty=%d', selection, quantity)
end

return entity
