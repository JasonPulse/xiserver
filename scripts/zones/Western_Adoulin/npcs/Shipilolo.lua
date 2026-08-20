-----------------------------------
-- Area: Western Adoulin
--  NPC: Shipilolo
--  Involved with Quests: 'A Certain Substitute Patrolman'
--                        'Fertile Ground'
--                        'Wayward Waypoints'
-- !pos 84 0 -60 256
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local fertileGround = player:getQuestStatus(xi.questLog.ADOULIN, xi.quest.id.adoulin.FERTILE_GROUND)

    if player:getCurrentMission(xi.mission.log_id.SOA) >= xi.mission.id.soa.LIFE_ON_THE_FRONTIER then
        -- The Old Man and the Harpoon's csid 2543 branch was removed from this
        -- file: scripts/quests/adoulin/The_Old_Man_and_the_Harpoon.lua owns 2540
        -- through 2543, and onEventFinish runs BOTH the framework handler and this
        -- fallback (interaction_lookup.lua:412 excludes only onSteal/onTrigger/
        -- onTrade), so the Broken -> Extravagant harpoon swap fired twice. The rest
        -- of this file -- Fertile Ground and Wayward Waypoints -- has no framework
        -- counterpart and is kept.
        if
            fertileGround == xi.questStatus.QUEST_ACCEPTED and
            not player:hasKeyItem(xi.ki.BOTTLE_OF_FERTILIZER_X)
        then
            -- Progresses Quest: 'Fertile Ground'
            player:startEvent(2850)
        elseif
            player:getQuestStatus(xi.questLog.ADOULIN, xi.quest.id.adoulin.WAYWARD_WAYPOINTS) == xi.questStatus.QUEST_ACCEPTED and
            player:getCharVar('WW_Need_Shipilolo') > 0 and
            not player:hasKeyItem(xi.ki.WAYPOINT_RECALIBRATION_KIT)
        then
            -- Progresses Quest: 'Wayward Waypoints'
            player:startEvent(79)
        end
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 2850 then
        -- Progresses Quest: 'Fertile Ground' TODO: Should this also give the player a message?
        player:addKeyItem(xi.ki.BOTTLE_OF_FERTILIZER_X)
    elseif csid == 79 then
        player:addKeyItem(xi.ki.WAYPOINT_RECALIBRATION_KIT)
        player:setCharVar('WW_Need_Shipilolo', 0)
    end
end

return entity
