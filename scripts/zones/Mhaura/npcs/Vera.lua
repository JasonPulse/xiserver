-----------------------------------
-- Area: Mhaura
--  NPC: Vera
-- Finishes Quest: The Old Lady
-- !pos -49 -5 20 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ELDER_MEMORIES) ~= xi.questStatus.QUEST_AVAILABLE then
        player:startEvent(130)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
