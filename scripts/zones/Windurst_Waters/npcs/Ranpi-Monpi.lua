-----------------------------------
-- Area: Windurst Waters
--  NPC: Ranpi-Monpi
-- Starts and Finishes Quest: A Crisis in the Making
-- Involved in quest: In a Stew, For Want of a Pot, The Dawn of Delectability
-- !pos -116 -3 52  238
-- (outside the shop he is in)
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local rand = math.random(1, 3)

    if rand == 1 then
        player:startEvent(249)
    elseif rand == 2 then
        player:startEvent(251)
    else
        player:startEvent(256)
    end
end

return entity
