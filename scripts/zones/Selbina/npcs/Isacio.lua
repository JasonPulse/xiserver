-----------------------------------
-- Area: Selbina
--  NPC: Isacio
-- Finishes Quest: Elder Memories
-- !pos -54 -1 -44 248
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.THE_OLD_LADY) ~= xi.questStatus.QUEST_AVAILABLE then
        player:startEvent(99)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
