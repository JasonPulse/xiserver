-----------------------------------
-- Area: Mhaura
--  NPC: Nereus
-- Starts and ends repeteable quest A_POTTERS_PREFERENCE
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    player:startEvent(110)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
