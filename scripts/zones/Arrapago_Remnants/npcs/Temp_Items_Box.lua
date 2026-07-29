-----------------------------------
-- Ported from Mishffera/lsb-server (https://github.com/Mishffera/lsb-server)
-- Source of Silver Sea Remnants + Lebros Assault content; adapted to this fork.
-----------------------------------
-----------------------------------
-- Area: Arrapago Remnants
-- NPC: Temp Items Box
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local instance = player:getInstance()

    if not instance then
        return
    end

    xi.salvage.tempBoxTrigger(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.salvage.tempBoxFinish(player, csid, option, npc)
end

return entity
