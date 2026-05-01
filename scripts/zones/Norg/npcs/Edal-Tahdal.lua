-----------------------------------
-- Area: Norg
--  NPC: Edal-Tahdal
-- Starts and Finishes Quest: Trial by Water
-- !pos -13 1 -20 252
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(113)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
