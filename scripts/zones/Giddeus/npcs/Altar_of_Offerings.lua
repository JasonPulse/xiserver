-----------------------------------
-- Area: Giddeus
--  NPC: Alter of Offerings
-- Involved in Quest: A Crisis in the Making
-- !pos -137 17 177 145
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(60)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
