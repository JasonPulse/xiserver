-----------------------------------
-- Area: Windurst Woods
--  NPC: Tapoh Lihzeh
-- Starts & Finishes Repeatable Quest: Paying Lip Service
-- !pos 51.011 -3.749 54.402 241
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(437)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
