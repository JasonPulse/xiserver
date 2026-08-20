-----------------------------------
-- Area: Abyssea - Vunkerl
--  NPC: Repair Trunk
-- Involved in Quest: Ward Warden I, Desert Rain I
-----------------------------------
-- Two usable trunks per zone, told apart by the sack their own data[] carries: the
-- repair-materials trunk holds the hempen sack (1627, Ward Warden) and the
-- provisions trunk the flaxen sack (1628, Desert Rain). Entity ids and csids are
-- from `xi-dat events 217`; the zone's other Repair_Trunk entities own no csids
-- and are scenery. Packing logic lives in
-- scripts/globals/abyssea/resistance_sapper.lua.
-----------------------------------
require('scripts/globals/abyssea/resistance_sapper')
-----------------------------------
---@type TNpcEntity
local entity = {}

-- entity id -> { cargo sack, csid that opens its cram menu }
local trunks =
{
    [17666773] = { xi.ki.MAGICKED_HEMPEN_SACK, 1508 },
    [17666774] = { xi.ki.MAGICKED_FLAXEN_SACK, 1511 },
}

entity.onTrigger = function(player, npc)
    local trunk = trunks[npc:getID()]
    if trunk == nil then
        return
    end

    xi.abyssea.sapper.trunkOnTrigger(player, npc, trunk[1], trunk[2])
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.abyssea.sapper.trunkOnEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
