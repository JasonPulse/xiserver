-----------------------------------
-- Area: Mog Garden (280)
--  NPC: Garden Furrow #3 (plot 3)
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
