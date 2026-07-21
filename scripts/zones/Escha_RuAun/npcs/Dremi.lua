-----------------------------------
-- Area: Escha - Ru'Aun
--  NPC: Dremi
-- Eschan hub vendor (grisly-trinket notes / key-item shop / vorseals) +
-- Geas Fete NM pops are at the daises, not here. Vendor menu is client
-- event 9704; the handler in eschan_hub.lua is a decode instrument this
-- session (logs the 9704 option protocol for the live-tune pass).
-- !pos see npc_list 17961711 289
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.eschanHub.onSageTrigger(player, 'Dremi', xi.ki.MAP_OF_ESCHA_RUAUN)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.eschanHub.onSageEventUpdate(player, 'Dremi', csid, option)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.eschanHub.onSageEventFinish(player, 'Dremi', csid, option)
end

return entity
