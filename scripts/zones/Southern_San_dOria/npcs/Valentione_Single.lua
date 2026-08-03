-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Valentione Single
-- Only visible during the Valentione's Day seasonal event
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.events.valentione then
        xi.events.valentione.onSingleTrigger(player, npc)
    end
end

entity.onTrade = function(player, npc, trade)
    if xi.events.valentione then
        xi.events.valentione.onSingleTrade(player, npc, trade)
    end
end

return entity
