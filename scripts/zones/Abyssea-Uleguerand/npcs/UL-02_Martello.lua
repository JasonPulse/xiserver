-----------------------------------
-- Area: Abyssea - Uleguerand
--  NPC: UL-02 Martello
-- Martello tower: full HP/MP restore + status cleanse from the tower's
-- energy pool (see scripts/globals/abyssea/martello.lua).
-----------------------------------
require('scripts/globals/abyssea/martello')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.abyssea.martelloOnTrigger(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
