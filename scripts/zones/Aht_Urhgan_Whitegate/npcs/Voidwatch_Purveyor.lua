-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Voidwatch Purveyor
-- Entity 16982636 (0x0103226C) is the sole owner of csid 968, a 2400-byte
-- program -- but 968 is NOT a shop menu. Decoded with xidat/csidmsg.py it emits
-- Whitegate dialog 14225/14229/14235-14244, which is the Promotion: Captain
-- award ceremony: 14235 'Congratulations!', 14239 'Captain Privileges, Number
-- One! Mercenaries with the rank of captain are exempt from the fee charged for
-- ${keyitem-plural}', 14241 the Alzadaal fee exemption. The earlier
-- "CSID 968 verified via xidat" note was wrong about what it verified.
--
-- This NPC row is a custom Voidwatch addition (npc_list content tag VOIDWATCH)
-- layered onto a client entity that SE used for the Captain ceremony, so there
-- is no real purveyor event on it to find. It is currently status=0 in
-- npc_list -- hidden and not clickable -- so firing 968 has no player-facing
-- effect today, but it must not ship enabled as-is or clicking the purveyor
-- would play the Captain promotion cutscene.
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
