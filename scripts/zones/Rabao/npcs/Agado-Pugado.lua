-----------------------------------
-- Area: Rabao
--  NPC: Agado-Pugado
-- Starts and Finishes Quest: Trial by Wind
-- !pos -17 7 -10 247
-----------------------------------
local ID = zones[xi.zone.RABAO]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local carbuncleDebacle = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CARBUNCLE_DEBACLE)
    local progress = player:getCharVar('CarbuncleDebacleProgress')

    if
        carbuncleDebacle == xi.questStatus.QUEST_ACCEPTED and
        progress == 5 and
        player:hasKeyItem(xi.ki.DAZE_BREAKER_CHARM)
    then
        player:startEvent(86)
    elseif
        carbuncleDebacle == xi.questStatus.QUEST_ACCEPTED and
        progress == 6
    then
        if not player:hasItem(xi.item.WIND_PENDULUM) then
            player:startEvent(87, 0, xi.item.WIND_PENDULUM, 0, 0, 0, 0, 0, 0)
        else
            player:startEvent(88)
        end
    else
        player:startEvent(70)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 86 or csid == 87 then
        if player:getFreeSlotsCount() ~= 0 then
            player:addItem(xi.item.WIND_PENDULUM)
            player:messageSpecial(ID.text.ITEM_OBTAINED, xi.item.WIND_PENDULUM)
            player:setCharVar('CarbuncleDebacleProgress', 6)
        else
            player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.WIND_PENDULUM)
        end
    end
end

return entity
