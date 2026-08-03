-----------------------------------
-- Area: Port Windurst
--  NPC: Ome
-- Only visible during the New Year's seasonal event
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.events.newYears then
        xi.events.newYears.onOmeTrigger(player, npc)
    end
end

return entity
