-----------------------------------
-- Area: Northern San d'Oria
--  NPC: Pagisalis
-- Involved In Quest: Enveloped in Darkness
-- !zone 231
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(564)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
