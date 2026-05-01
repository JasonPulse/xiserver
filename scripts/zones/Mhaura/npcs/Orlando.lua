-----------------------------------
-- Area: Mhaura
--  NPC: Orlando
-- !pos -37.268 -9 58.047 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(100)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
