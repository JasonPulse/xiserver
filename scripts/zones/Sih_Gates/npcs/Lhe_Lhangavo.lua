-----------------------------------
-- Area: Sih Gates
--  NPC: Lhe Lhangavo (Sinister Reign dispatcher)
-- Entity 17875320 ; CSIDs (sentinels): 13, 14. Verified via xidat.
-- Using 13 as entry per global module table.
-----------------------------------
require('scripts/globals/sinister_reign')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sinisterReign.lheLhangavoOnTrigger(player, npc, 'SihGates')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventUpdate(player, csid, option, 'SihGates')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventFinish(player, csid, option, 'SihGates')
end

return entity
