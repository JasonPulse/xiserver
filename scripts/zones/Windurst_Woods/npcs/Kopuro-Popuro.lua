-----------------------------------
-- Area: Windurst Woods
--  NPC: Kopuro-Popuro
-- !pos -0.037 -4.749 -22.589 241
-- Starts Quests: The All-New C-2000, Legendary Plan B, The All-New C-3000
-- Involved in quests: Lost Chick, A Greeting Cardian
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local aGreetingCardian = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.A_GREETING_CARDIAN)
    local aGreetingCardianCS = player:getCharVar('AGreetingCardian_Event')

    -- A GREETING CARDIAN
    if
        aGreetingCardian == xi.questStatus.QUEST_ACCEPTED and
        aGreetingCardianCS == 5
    then
        player:startEvent(301)
    else
        player:startEvent(276)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
