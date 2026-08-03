-----------------------------------
-- Area: West Ronfaure
--  NPC: Saradorial
-- Only visible during the Sunbreeze Festival seasonal event
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.events.sunbreeze then
        xi.events.sunbreeze.onPondTrigger(player, npc)
    end
end

entity.onTrade = function(player, npc, trade)
    if xi.events.sunbreeze then
        xi.events.sunbreeze.onPondTrade(player, npc, trade)
    end
end

return entity
