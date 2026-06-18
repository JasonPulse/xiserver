-----------------------------------
-- Area: Meriphataud Mountains
--  NPC: Riftworn Pyxis (Voidwatch reward claim)
-- Entities 17265318-20 ; CSIDs 6003-6005 verified via xidat.
-----------------------------------
require('scripts/globals/voidwatch')
-----------------------------------
---@type TNpcEntity
local entity = {}

local function pyxiseventForNpc(npcId)
    local zoneFirstPyxis = 17265318
    local offset         = npcId - zoneFirstPyxis
    return 6003 + offset
end

entity.onTrigger = function(player, npc)
    local voidstones = xi.voidwatch.getVoidstoneCount(player)
    local csid       = pyxiseventForNpc(npc:getID())

    printf('[Riftworn_Pyxis_Meri] onTrigger: npc=%d csid=%d voidstones=%d',
        npc:getID(), csid, voidstones)

    player:startEvent(csid, voidstones, 0, 0, 0, 0, 0, 0)
end

entity.onEventUpdate = function(player, csid, option, npc)
    printf('[Riftworn_Pyxis_Meri] onEventUpdate: csid=%d option=%d (0x%08X)', csid, option, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    printf('[Riftworn_Pyxis_Meri] onEventFinish: csid=%d option=%d (0x%08X)', csid, option, option)

    if option ~= 0 and option ~= 0xFFFFFFFF then
        xi.voidwatch.consumeVoidstone(player)
    end
end

return entity
