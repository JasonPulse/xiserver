-----------------------------------
-- Area: Southern San dOria (S)
--  NPC: Scarlette, C.A.
-- Type: Campaign Arbiter (opens the campaign operations menu)
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(459)
end

return entity
