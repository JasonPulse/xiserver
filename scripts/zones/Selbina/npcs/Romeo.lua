-----------------------------------
-- Area: Selbina
--  NPC: Romeo
-- Starts and Finishes Quest: Donate to Recycling
-- !pos -11 -11 -6 248
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(23)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
