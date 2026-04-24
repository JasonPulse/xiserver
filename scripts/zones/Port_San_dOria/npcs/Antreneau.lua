-----------------------------------
-- Area: Port San d'Oria
--  NPC: Antreneau
-- !pos -71 -5 -39 232
-- Involved in Quests: A Taste For Meat, Over The Hills And Far Away
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    player:startEvent(532) -- What's this?  I don't need this.
end

entity.onTrigger = function(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
