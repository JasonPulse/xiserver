-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Jaded Hawk
-- Adoulin delivery box NPC
-- !pos -38 -0.150 -98 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(7585)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
