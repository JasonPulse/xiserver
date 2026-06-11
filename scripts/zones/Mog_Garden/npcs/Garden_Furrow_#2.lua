-----------------------------------
-- Area: Mog Garden (280)
--  NPC: Garden Furrow #2 (plot 2)
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.mog_garden.furrowOnTrade(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    xi.mog_garden.furrowOnTrigger(player, npc)
end

return entity
