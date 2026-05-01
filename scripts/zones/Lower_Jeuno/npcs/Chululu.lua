-----------------------------------
-- Area: Lower Jeuno
--  NPC: Chululu
-- Starts and Finishes Quests: Collect Tarut Cards, Rubbish Day, All in the Cards
-- Optional Cutscene at end of Quest: Searching for the Right Words
-- !pos -13 -6 -42 245
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.SEARCHING_FOR_THE_RIGHT_WORDS) == xi.questStatus.QUEST_COMPLETED then
        if player:getCharVar('SearchingForRightWords_postcs') < -1 then
            player:startEvent(56)
        else
            player:startEvent(57)
        end
    else
        player:startEvent(26)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
