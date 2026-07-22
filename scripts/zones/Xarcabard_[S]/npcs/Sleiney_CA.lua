-----------------------------------
-- Area: Xarcabard (S)
--  NPC: Sleiney, C.A.
-- Type: Campaign Arbiter (opens the campaign operations menu)
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(453)
end

return entity
