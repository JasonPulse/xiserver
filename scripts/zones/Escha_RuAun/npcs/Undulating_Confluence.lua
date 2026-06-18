-----------------------------------
-- Area: Escha - Ru'Aun (289)
--  NPC: Undulating Confluence
-- !pos -0.163 -34.106 -471.971 289
--
-- Doubles as a Geas Fete / Wildskeeper Reive pop trigger: if the player
-- holds (or has pinned via Pop_Selection CharVar) a pop KI mapped to this
-- zone, the boss spawns and the KI is consumed before the teleport menu
-- fires.
-----------------------------------
require('scripts/globals/pop_trigger')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.popTrigger.tryPop(player) then
        return
    end

    player:startEvent(1)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 1 and option == 1 then
        xi.teleport.to(player, xi.teleport.id.MISAREAUX_CONFLUENCE)
    end
end

return entity
