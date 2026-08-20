-----------------------------------
-- Area: Crawlers_Nest_[S]
--  NPC: Rodeupansat
-- Starts and Finishes Quest: EVIL_AT_THE_INLET
-- !pos 129 -34 26 171
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local evilAtTheInlet = player:getQuestStatus(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.EVIL_AT_THE_INLET)

    -- Change to BRASS_RIBBON_OF_SERVICE later when Campaign has been added.
    if
        evilAtTheInlet == xi.questStatus.QUEST_AVAILABLE and
        -- bg-wiki |Level= is blank for this quest; the `getMainLvl() >= 30` test
        -- that used to be here is not a retail requirement. The ribbon stays BRONZE
        -- deliberately -- bg-wiki asks for the Brass Ribbon of Service, which comes
        -- from Campaign, and Campaign is not implemented here (see the note above).
        player:hasKeyItem(xi.ki.BRONZE_RIBBON_OF_SERVICE)
    then
        player:startEvent(107) -- Start quest "Evil at the Inlet"
    elseif evilAtTheInlet == xi.questStatus.QUEST_ACCEPTED then
        if player:hasKeyItem(xi.ki.EVIL_WARDING_SEAL) then
            player:startEvent(108) -- During quest after receiving KI and before losing KI
        else
            player:startEvent(109) -- After losing KI and returning for reward
        end
    elseif evilAtTheInlet == xi.questStatus.QUEST_COMPLETED then
        player:startEvent(110) -- New standard dialog after "Evil at the Inlet"
    else
        player:startEvent(106) -- Standard dialog
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 107 then
        player:addQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.EVIL_AT_THE_INLET)
        npcUtil.giveKeyItem(player, xi.ki.EVIL_WARDING_SEAL)
    elseif csid == 109 then
        npcUtil.completeQuest(player, xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.EVIL_AT_THE_INLET, { item = xi.item.SCROLL_OF_RECALL_JUGNER })
    end
end

return entity
