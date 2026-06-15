-----------------------------------
-- Area: East Ronfaure
--  NPC: Planar Rift (Voidwatch battle entry)
-- Entities 17191577-79 ; CSIDs 6000-6002 (Voidwatch battle entry events,
-- each ~17.9KB — full retail battle / menu logic verified via xidat).
-- All 3 rift instances share the same Lua script — the engine's event VM
-- handles the per-rift state based on entity ID + chapter/path lookup.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local function rifteventForNpc(npcId)
    -- Map each of the 3 rift entity IDs to its CSID. The IDs are
    -- sequential in npc_list.sql so we compute the offset from the
    -- first rift in the zone.
    local zoneFirstRift = 17191577
    local offset        = npcId - zoneFirstRift
    return 6000 + offset
end

entity.onTrigger = function(player, npc)
    if not xi.voidwatch.hasAlarum(player) then
        player:printToPlayer('You require a Voidwatch Alarum to interact with a Planar Rift.')
        return
    end

    local cruor      = player:getCurrency('cruor')
    local voidstones = xi.voidwatch.getVoidstoneCount(player)
    local capacity   = xi.voidwatch.getVoidstoneCapacity(player)
    local csid       = rifteventForNpc(npc:getID())

    printf('[Planar_Rift_ERon] onTrigger: npc=%d csid=%d voidstones=%d/%d cruor=%d',
        npc:getID(), csid, voidstones, capacity, cruor)

    player:startEvent(csid, voidstones, capacity, cruor, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[Planar_Rift_ERon] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[Planar_Rift_ERon] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)
end

return entity
