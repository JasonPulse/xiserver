-----------------------------------
-- Area: Qufim Island
--  NPC: Voidwatch Officer
-- Entity 17293815 ; CSIDs verified via xidat (size signature matches
-- the Bastok Markets / Southern San d'Oria template:
-- 631 / 1377 / 1377 / 640 / 640 / 600 / 600 / 2034 / 12089).
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    MAIN_MENU        = 52,
    MAIN_MENU_PAST   = 53,
    OPS_BRIEFING     = 54,
    SUB_MENU_1       = 55,
    SUB_MENU_2       = 56,
    SUB_MENU_3       = 57,
    SUB_MENU_4       = 58,
    SUB_MENU_5       = 59,
    SHARED           = 50,
}

entity.onTrigger = function(player, npc)
    local cruor      = player:getCurrency('cruor')
    local voidstones = xi.voidwatch.getVoidstoneCount(player)
    local capacity   = xi.voidwatch.getVoidstoneCapacity(player)

    local stratumBits = 0
    for path = 1, 8 do
        local tier = xi.voidwatch.getPathTier(player, path)
        if tier > 0 then
            stratumBits = bit.bor(stratumBits, bit.lshift(tier, (path - 1) * 4))
        end
    end

    printf('[VW_Officer_Qufim] onTrigger: cruor=%d voidstones=%d capacity=%d stratumBits=%d',
        cruor, voidstones, capacity, stratumBits)

    player:startEvent(csids.MAIN_MENU, cruor, voidstones, capacity, stratumBits, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[VW_Officer_Qufim] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[VW_Officer_Qufim] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local subOption = bit.band(bit.rshift(option, 8), 0xFF)
    local param3    = bit.band(bit.rshift(option, 16), 0xFF)
    local param4    = bit.band(bit.rshift(option, 24), 0xFF)
    printf('[VW_Officer_Qufim]   parsed: sel=%d sub=%d p3=%d p4=%d', selection, subOption, param3, param4)
end

return entity
