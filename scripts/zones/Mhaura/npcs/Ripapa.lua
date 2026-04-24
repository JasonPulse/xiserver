-----------------------------------
-- Area: Mhaura
--  NPC: Ripapa
-- Starts and Finishes Quest: Trial by Lightning
-- !pos 29 -15 55 249
-----------------------------------
local ID = zones[xi.zone.MHAURA]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local carbuncleDebacle = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CARBUNCLE_DEBACLE)
    local progress = player:getCharVar('CarbuncleDebacleProgress')

    if
        carbuncleDebacle == xi.questStatus.QUEST_ACCEPTED and
        progress == 2
    then
        player:startEvent(10022)
    elseif
        carbuncleDebacle == xi.questStatus.QUEST_ACCEPTED and
        progress == 3 and
        not player:hasItem(xi.item.LIGHTNING_PENDULUM)
    then
        player:startEvent(10023, 0, xi.item.LIGHTNING_PENDULUM, 0, 0, 0, 0, 0, 0)
    else
        player:startEvent(10020)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 10022 or csid == 10023 then
        if player:getFreeSlotsCount() ~= 0 then
            player:addItem(xi.item.LIGHTNING_PENDULUM)
            player:messageSpecial(ID.text.ITEM_OBTAINED, xi.item.LIGHTNING_PENDULUM)
            player:setCharVar('CarbuncleDebacleProgress', 3)
        else
            player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.LIGHTNING_PENDULUM)
        end
    end
end

return entity
