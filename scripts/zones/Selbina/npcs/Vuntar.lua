-----------------------------------
-- Area: Selbina
--  NPC: Vuntar
-- Starts and Finishes Quest: Cargo (R)
-- !pos 7 -2 -15 248
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:getMainLvl() < 20 then
        player:startEvent(53)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
