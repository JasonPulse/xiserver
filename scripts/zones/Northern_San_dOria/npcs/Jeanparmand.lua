-----------------------------------
-- Area: Northern San dOria
--  NPC: Jeanparmand
-- Only visible during the New Year's seasonal event
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.events.newYears then
        xi.events.newYears.onBattledoreTrigger(player, npc)
    end
end

entity.onTrade = function(player, npc, trade)
    if xi.events.newYears then
        xi.events.newYears.onBattledoreTrade(player, npc, trade)
    end
end

return entity
