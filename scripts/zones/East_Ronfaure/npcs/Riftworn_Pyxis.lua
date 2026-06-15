-----------------------------------
-- Area: East Ronfaure
--  NPC: Riftworn Pyxis (Voidwatch reward claim)
-- Entities 17191580-82 ; CSIDs 6003-6005 (Voidwatch reward events,
-- ~1.3KB each — claim menu / loot distribution verified via xidat).
-- Spawned after Voidwatch NM death; consumes 1 Voidstone on reward claim.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local function pyxiseventForNpc(npcId)
    local zoneFirstPyxis = 17191580
    local offset         = npcId - zoneFirstPyxis
    return 6003 + offset
end

entity.onTrigger = function(player, npc)
    local voidstones = xi.voidwatch.getVoidstoneCount(player)
    local csid       = pyxiseventForNpc(npc:getID())

    printf('[Riftworn_Pyxis_ERon] onTrigger: npc=%d csid=%d voidstones=%d',
        npc:getID(), csid, voidstones)

    player:startEvent(csid, voidstones, 0, 0, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[Riftworn_Pyxis_ERon] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[Riftworn_Pyxis_ERon] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    -- Per VOIDWATCH_TODO Phase 3D: Voidstone consumed on reward claim,
    -- not battle entry. If player picks a reward (option > 0), consume.
    if option ~= 0 and option ~= 0xFFFFFFFF then
        xi.voidwatch.consumeVoidstone(player)
    end
end

return entity
