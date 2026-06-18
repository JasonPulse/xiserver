-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Lhe Lhangavo (Sinister Reign dispatcher)
-- Entity 17830040 ; CSIDs (all sentinels): 1500, 1532, 1533, 1535,
-- 1551, 1552, 1549. Verified via xidat. Using 1500 as entry per global
-- module table.
-----------------------------------
require('scripts/globals/sinister_reign')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sinisterReign.lheLhangavoOnTrigger(player, npc, 'EAdoulin')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventUpdate(player, csid, option, 'EAdoulin')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventFinish(player, csid, option, 'EAdoulin')
end

return entity
