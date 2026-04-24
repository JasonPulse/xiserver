-----------------------------------
-- Area: Lower Jeuno
--  NPC: Vola
-- Starts and Finishes Quest: Fistful of Fury
-- Involved in Quests: Beat Around the Bushin (before the quest)
-- !pos 43 3 -45 245
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local beatAroundTheBushin = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.BEAT_AROUND_THE_BUSHIN)

    if
        beatAroundTheBushin == xi.questStatus.QUEST_AVAILABLE and
        player:getMainJob() == xi.job.MNK and
        player:getMainLvl() >= 71 and
        player:getFameLevel(xi.fameArea.NORG) >= 6
    then
        player:startEvent(160) -- Start Quest "Beat Around the Bushin"
    elseif beatAroundTheBushin ~= xi.questStatus.QUEST_AVAILABLE then
        player:startEvent(214) -- During & After Quest "Beat Around the Bushin"
    else
        player:startEvent(212) -- Standard dialog
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if
        csid == 160 and
        player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.BEAT_AROUND_THE_BUSHIN) == xi.questStatus.QUEST_AVAILABLE
    then
        player:setCharVar('BeatAroundTheBushin', 1)
    end
end

return entity
