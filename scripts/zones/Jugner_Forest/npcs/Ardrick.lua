-----------------------------------
-- Area: Jugner Forest
--  NPC: Ardrick
-- Voidwatch chapter NPC — handles Voidwatch_Officer-equivalent ops in
-- the wilderness zones.
-- Entity 17203945 ; CSIDs 61(825b) + 62(747b) verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local csids =
{
    MAIN_MENU  = 61,
    OPS_REPORT = 62,
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

    printf('[Ardrick] onTrigger: cruor=%d voidstones=%d capacity=%d stratumBits=%d',
        cruor, voidstones, capacity, stratumBits)

    player:startEvent(csids.MAIN_MENU, cruor, voidstones, capacity, stratumBits, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[Ardrick] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[Ardrick] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option == 0 or option == 0xFFFFFFFF then
        return
    end

    local selection = bit.band(option, 0xFF)
    local subOption = bit.band(bit.rshift(option, 8), 0xFF)
    printf('[Ardrick]   parsed: sel=%d sub=%d', selection, subOption)
end

return entity
