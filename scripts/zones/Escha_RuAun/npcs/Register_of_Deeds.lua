-----------------------------------
-- Area: Escha - Ru'Aun
--  NPC: Register of Deeds
-- Domain Points reward catalog. Client menu program is CSID 9708 —
-- verified via xidat for all three Escha hub registers. The event
-- parameter contract is not decoded yet; until it is, players get the
-- catalog/trade flow and the real menu fires only in decode mode
-- (!setvar EschaMenuDecode 1) with full option logging.
-- !pos see npc_list 17961712 289
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    REGISTER_MENU = 9708,
}

entity.onTrigger = function(player, npc)
    if player:getCharVar('EschaMenuDecode') == 1 then
        local points = player:getCurrency('domain_points')
        printf('[RegisterOfDeeds] probe onTrigger: dp=%d', points)
        player:startEvent(csids.REGISTER_MENU, points, 0, 0, 0, 0, 0, 0, 0)
        return
    end

    xi.eschanHub.onRegisterTrigger(player)
end

entity.onTrade = function(player, npc, trade)
    xi.eschanHub.onRegisterTrade(player, trade)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[RegisterOfDeeds] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[RegisterOfDeeds] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)
end

return entity
