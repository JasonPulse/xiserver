-----------------------------------
-- Area: Abyssea - Vunkerl
--  NPC: Resistance Sapper
-- Involved in Quest: Ward Warden I, Ward Warden II, Desert Rain I, Desert Rain II, Crimson Carpet I, Crimson Carpet II
-----------------------------------
-- All six operations run off one client menu (csid 1503, message 7949). The logic
-- is shared across all three sapper zones in
-- scripts/globals/abyssea/resistance_sapper.lua -- this script only forwards.
-----------------------------------
require('scripts/globals/abyssea/resistance_sapper')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.abyssea.sapper.sapperOnTrigger(player, npc)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.abyssea.sapper.sapperOnEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.abyssea.sapper.sapperOnEventFinish(player, csid, option, npc)
end

return entity
