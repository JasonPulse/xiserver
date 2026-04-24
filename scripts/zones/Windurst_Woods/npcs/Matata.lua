-----------------------------------
-- Area: Windurst Woods
--  NPC: Matata
-- Involved in quest: In a Stew
-- !pos 131 -5 -109 241
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(223)
end

return entity
