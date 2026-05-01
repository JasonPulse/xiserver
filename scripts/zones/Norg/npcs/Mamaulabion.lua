-----------------------------------
-- Area: Norg
--  NPC: Mamaulabion
-- Starts and finishes Quest: Mama Mia
-- !pos -57 -9 68 252
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(93)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
