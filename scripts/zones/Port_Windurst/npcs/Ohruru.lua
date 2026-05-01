-----------------------------------
-- Area: Port Windurst
--  NPC: Ohruru
-- Starts & Finishes Repeatable Quest: Catch me if you can
-- Involved in Quest: Wonder Wands
-- Note: Animation for his "Cure" is not functioning. Unable to capture option 1, so if the user says no, he heals them anyways.
-- !pos -108 -5 94 240
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local wonderWands = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.WONDER_WANDS)

    if wonderWands == xi.questStatus.QUEST_ACCEPTED then
        player:startEvent(258, 0, 17053)
    elseif wonderWands == xi.questStatus.QUEST_COMPLETED then
        player:startEvent(265)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
