-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Malulu
-- Adoulin delivery box NPC
-- !pos -34 -0.150 -118 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(7584)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
