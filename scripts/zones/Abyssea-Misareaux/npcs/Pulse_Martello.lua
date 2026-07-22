-----------------------------------
-- Area: Abyssea - Misareaux
--  NPC: Pulse Martello
-- Upgraded martello tower — same recovery service as the field martellos
-- (see scripts/globals/abyssea/martello.lua).
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
