-----------------------------------
-- Area: Lower Jeuno
-- Starts and Finishes Quest: Your Crystal Ball & Never to return
-- !pos -4 -6 -28 245
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local searchingForTheRightWords = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.SEARCHING_FOR_THE_RIGHT_WORDS)
    local rubbishDay                = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.RUBBISH_DAY)
    local neverToReturn             = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.NEVER_TO_RETURN)
    local searchingForWordsPrereq   = player:getCharVar('QuestSearchRightWords_prereq')

    -- searching for right words flow
    if searchingForWordsPrereq == 1 then
        player:startEvent(38)
    elseif player:getCharVar('QuestSearchRightWords_denied') == 1 then
        player:startEvent(36)
    elseif searchingForTheRightWords == xi.questStatus.QUEST_ACCEPTED then
        player:startEvent(39)
    elseif player:getCharVar('SearchingForRightWords_postcs') == -2 then
        player:startEvent(154)
    elseif searchingForTheRightWords == xi.questStatus.QUEST_COMPLETED then
        player:startEvent(37)

    -- searching for right words prereq gate
    -- bg-wiki header: |Fame=Jeuno |FLevel=6. The three previous quests were
    -- checked but the fame level was not, so the quest could be flagged well
    -- below the required standing. (A sibling file claims the fame is
    -- "implicitly stored" by the prerequisites -- it is not; nothing in that
    -- chain enforces level 6.)
    elseif
        player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.A_CANDLELIGHT_VIGIL) == xi.questStatus.QUEST_COMPLETED and
        rubbishDay == xi.questStatus.QUEST_COMPLETED and
        neverToReturn == xi.questStatus.QUEST_COMPLETED and
        searchingForTheRightWords == xi.questStatus.QUEST_AVAILABLE and
        player:getFameLevel(xi.fameArea.JEUNO) >= 6
    then
        player:startEvent(17)
    else
        player:startEvent(193)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 17 then
        player:setCharVar('QuestSearchRightWords_prereq', 1)
    elseif csid == 154 then
        player:setCharVar('SearchingForRightWords_postcs', -1)
    end
end

return entity
