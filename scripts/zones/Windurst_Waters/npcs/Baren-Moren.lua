-----------------------------------
-- Area: Windurst Waters
--  NPC: Baren-Moren
-- Starts and Finishes Quest: Hat in Hand
-- !pos -66 -3 -148 238
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local hatInHand = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.HAT_IN_HAND)

    if
        hatInHand == xi.questStatus.QUEST_AVAILABLE and
        player:getVar('Quest[2][23]Prog') == 0 -- Quest progress in "All At Sea" blocks "Hat In Hand" from starting
    then
        player:startEvent(48) -- Quest Offered
    elseif player:hasKeyItem(xi.ki.NEW_MODEL_HAT) then
        local count = player:getCharVar('QuestHatInHand_count')

        if count >= 8 then
            player:startEvent(52, 80) -- 80 = HAT + FULL REWARD = 8 NPCS
            player:setLocalVar('hatRewardTier', 5)
        elseif count >= 6 then
            player:startEvent(52, 50) -- 50 = HAT + GOOD REWARD >= 6-7 NPCS
            player:setLocalVar('hatRewardTier', 4)
        elseif count >= 4 then
            player:startEvent(52, 30) -- 30 = PARTIAL REWARD >= 4-5 NPCS
            player:setLocalVar('hatRewardTier', 3)
        elseif count >= 2 then
            player:startEvent(52, 20) -- 20 = POOR REWARD >= 2-3 NPCS
            player:setLocalVar('hatRewardTier', 2)
        else
            player:startEvent(52) -- 0 = NO REWARD >= 0-1 NPCS
            player:setLocalVar('hatRewardTier', 1)
        end
    else
        local rand = math.random(1, 6)

        if rand == 1 then
            player:startEvent(42)
        elseif rand == 2 then
            player:startEvent(44)
        elseif rand == 3 then
            player:startEvent(45)
        elseif rand == 4 then
            player:startEvent(46)
        elseif rand == 5 then
            player:startEvent(47)
        elseif rand == 6 then
            player:startEvent(1022)
        end
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 48 and option == 1 then
        player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.HAT_IN_HAND)
        npcUtil.giveKeyItem(player, xi.ki.NEW_MODEL_HAT)
    elseif csid == 52 and option >= 1 then
        local rewardTier = player:getLocalVar('hatRewardTier')
        local rewards = { fame = 75, fameArea = xi.fameArea.WINDURST, var = { 'QuestHatInHand_var', 'QuestHatInHand_count' } }

        if rewardTier == 5 then
            rewards.gil = 500
            rewards.item = 12543
        elseif rewardTier == 4 then
            rewards.gil = 400
            rewards.item = 12543
        elseif rewardTier == 3 then
            rewards.gil = 300
        elseif rewardTier == 2 then
            rewards.gil = 150
        elseif rewardTier == 1 then
            rewards.gil = 300
        end

        if npcUtil.completeQuest(player, xi.questLog.WINDURST, xi.quest.id.windurst.HAT_IN_HAND, rewards) then
            player:delKeyItem(xi.ki.NEW_MODEL_HAT)
            player:needToZone(true)
        end
    end
end

return entity
