-----------------------------------
-- Area: Ceizak Battlegrounds
--  NPC: Lhe Lhangavo (Sinister Reign dispatcher)
-- Entity 17846786 ; CSID 19 (sentinel) verified via xidat.
-----------------------------------
require('scripts/globals/sinister_reign')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.sinisterReign.lheLhangavoOnTrigger(player, npc, 'Ceizak')
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventUpdate(player, csid, option, 'Ceizak')
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.sinisterReign.lheLhangavoOnEventFinish(player, csid, option, 'Ceizak')
end

return entity
