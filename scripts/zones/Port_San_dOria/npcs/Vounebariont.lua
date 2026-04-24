-----------------------------------
-- Area: Port San d'Oria
--  NPC: Vounebariont
-- Starts and Finishes Quest: Thick Shells
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(568)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
