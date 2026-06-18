-----------------------------------
-- Area: Jugner Forest
--  NPC: Planar Rift (Voidwatch battle entry)
-- Entities 17203939-41 ; CSIDs 6000-6002 verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local function rifteventForNpc(npcId)
    local zoneFirstRift = 17203939
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

    printf('[Planar_Rift_Jugner] onTrigger: npc=%d csid=%d voidstones=%d/%d cruor=%d',
        npc:getID(), csid, voidstones, capacity, cruor)

    player:startEvent(csid, voidstones, capacity, cruor, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[Planar_Rift_Jugner] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[Planar_Rift_Jugner] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)
end

return entity
