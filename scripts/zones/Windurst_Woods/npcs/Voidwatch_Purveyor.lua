-----------------------------------
-- Area: Windurst Woods
--  NPC: Voidwatch Purveyor
-- Entity 17764602 ; CSIDs 836(2400b)/848(1b) verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    SHOP_MENU = 836,
}

entity.onTrigger = function(player, npc)
    local points = player:getCP()
    printf('[VW_Purveyor_WindWoods] onTrigger: conquestPoints=%d', points)
    player:startEvent(csids.SHOP_MENU, 0, points, xi.voidwatch.PURVEYOR_ITEM_COST, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[VW_Purveyor_WindWoods] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[VW_Purveyor_WindWoods] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local quantity  = bit.band(bit.rshift(option, 8), 0xFF)
    printf('[VW_Purveyor_WindWoods]   parsed: sel=%d qty=%d', selection, quantity)
end

return entity
