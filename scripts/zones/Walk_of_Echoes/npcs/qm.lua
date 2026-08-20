-----------------------------------
-- Area: Walk of Echoes
--  NPC: qm
-- Zone 182 has seven entities named 'qm', so this script is shared by all of
-- them and dispatches on the entity id. Only the Moogle Magic ??? is handled
-- here; the others are left to fall through untouched.
-- !pos 0 0 0 182
-----------------------------------
local ID = zones[xi.zone.WALK_OF_ECHOES]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if npc:getID() == ID.npc.MOOGLE_MAGIC_QM then
        xi.kupofriedMoogleMagic.onTrade(player, npc, trade)
    end
end

entity.onTrigger = function(player, npc)
    if npc:getID() == ID.npc.MOOGLE_MAGIC_QM then
        xi.kupofriedMoogleMagic.onTrigger(player, npc)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.kupofriedMoogleMagic.onEventFinish(player, csid, option, npc)
end

return entity
