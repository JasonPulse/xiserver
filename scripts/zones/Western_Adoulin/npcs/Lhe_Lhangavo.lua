-----------------------------------
-- Area: Western Adoulin
--  NPC: Lhe Lhangavo (Sinister Reign dispatcher)
-- Entity 17825940 ; CSIDs (all sentinels): 5023, 5028, 135, 154, 158,
-- 185, 5221, 5225. Verified via xidat. Using 5023 as entry per global
-- module table.
-----------------------------------
require('scripts/globals/sinister_reign')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sinisterReign.lheLhangavoOnTrigger(player, npc, 'WAdoulin')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventUpdate(player, csid, option, 'WAdoulin')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventFinish(player, csid, option, 'WAdoulin')
end

return entity
