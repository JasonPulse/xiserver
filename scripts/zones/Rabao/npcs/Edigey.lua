-----------------------------------
-- Area: Rabao
--  NPC: Edigey
-- Starts and Ends Quest: Don't Forget the Antidote
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(50)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
