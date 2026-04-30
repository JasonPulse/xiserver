-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Lamaron
-- Boat to Yahse Hunting Grounds (G-5)
-- !pos -52 -0.650 96 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:startEvent(590)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 590 and option == 0 then
        player:setPos(361, 4, -211, 136, xi.zone.YAHSE_HUNTING_GROUNDS)
    end
end

return entity
