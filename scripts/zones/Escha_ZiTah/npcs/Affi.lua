-----------------------------------
-- Area: Escha - Zi'Tah
--  NPC: Affi
-- Eschan hub vendor (grisly-trinket notes / key-item shop / vorseals).
-- Geas Fete NM pops are at the daises, not here. Vendor menu is client
-- event 9700 (top menu 7556); the full menu tree + row<<8 selection encoding
-- are decoded from the client DAT (see eschan_hub.lua + xidat/eschavendor.py).
-- !pos -357 0.119 -170 288
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.eschanHub.onSageTrigger(player, 'Affi', xi.ki.MAP_OF_ESCHA_ZITAH)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.eschanHub.onSageEventUpdate(player, 'Affi', csid, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.eschanHub.onSageEventFinish(player, 'Affi', csid, option)
end

return entity
