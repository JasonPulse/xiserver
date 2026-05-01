-----------------------------------
-- Area: Kazham
--  NPC: Ronta-Onta
-- Starts and Finishes Quest: Trial by Fire
-- !pos 100 -15 -97 250
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(274)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
