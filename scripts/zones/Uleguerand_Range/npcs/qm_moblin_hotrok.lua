-----------------------------------
-- Area: Uleguerand_Range
--  NPC: ??? (Trade Moblin Hotrok for Map of Uleguerand Range)
-- !pos -299 -62 -18
-- Involved in Quests: Over The Hills And Far Away
-----------------------------------
local ID = zones[xi.zone.ULEGUERAND_RANGE]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.SOMETHING_GLITTERING_BUT)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
