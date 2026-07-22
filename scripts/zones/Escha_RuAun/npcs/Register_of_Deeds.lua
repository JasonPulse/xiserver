-----------------------------------
-- Area: Escha - Ru'Aun
--  NPC: Register of Deeds
-- Retail kill-records book (client event 9708): verify defeated notorious
-- monsters (star pages, fed from GeasFete_<mob>_Defeated CharVars) and
-- victory tallies. Handlers in eschan_hub.lua answer the event's
-- server-value requests each update.
-- !pos -10 -34 -458.5 289
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    xi.eschanHub.onRegisterTrigger(player)
end

entity.onTrade = function(player, npc, trade)
    xi.eschanHub.onRegisterTrade(player, trade)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.eschanHub.onRegisterEventUpdate(player, csid, option)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
