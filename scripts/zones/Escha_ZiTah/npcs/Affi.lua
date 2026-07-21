-----------------------------------
-- Area: Escha - Zi'Tah
--  NPC: Affi
-- Eschan hub vendor (grisly-trinket notes / key-item shop / vorseals) +
-- Geas Fete NM pops are at the daises, not here. Vendor menu is client
-- event 9704; the handler in eschan_hub.lua is a decode instrument this
-- session (logs the 9704 option protocol for the live-tune pass).
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
