-----------------------------------
-- Area: Norg
--  NPC: Muzaffar
-- Quests: Black Market
-- !pos 16.678 -2.044 -14.600 252
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 17 or csid == 18 or csid == 19 then
        player:startEvent(20)
    end
end

return entity
