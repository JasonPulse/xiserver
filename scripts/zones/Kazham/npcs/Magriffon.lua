-----------------------------------
-- Area: Kazham
--  NPC: Magriffon
-- Involved in Quest: Gullible's Travels, Even More Gullible's Travels,
-- Location: (I-7)
-----------------------------------
local ID = zones[xi.zone.KAZHAM]
-----------------------------------
---@type TNpcEntity
local entity = {}

local pathNodes =
{
    { x = 60.600, y = -12.000, z = -33.913, wait = 3000 },
    { z = -38.151, wait = 3000 },
}

entity.onSpawn = function(npc)
    if npc:getID() == ID.npc.MAGRIFFON then
        npc:initNpcAi()
        npc:setPos(xi.path.first(pathNodes))
        npc:pathThrough(pathNodes, xi.path.flag.PATROL)
    end
end

entity.onTrade = function(player, npc, trade)
    if
        player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.EVEN_MORE_GULLIBLES_TRAVELS) == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('EVEN_MORE_GULLIBLES_PROGRESS') == 0
    then
        if trade:getGil() >= 35000 then
            player:startEvent(150, 0, 256)
        end
    end
end

entity.onTrigger = function(player, npc)
    local gulliblesTravelsStatus = player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.GULLIBLES_TRAVELS)
    local evenmoreTravelsStatus = player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.EVEN_MORE_GULLIBLES_TRAVELS)

    if
        evenmoreTravelsStatus == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('EVEN_MORE_GULLIBLES_PROGRESS') == 0
    then
        player:startEvent(149, 0, 256, 0, 0, 0, 35000)
    elseif
        evenmoreTravelsStatus == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('EVEN_MORE_GULLIBLES_PROGRESS') == 1
    then
        player:startEvent(151)
    elseif
        evenmoreTravelsStatus == xi.questStatus.QUEST_ACCEPTED and
        player:getCharVar('EVEN_MORE_GULLIBLES_PROGRESS') == 2
    then
        player:startEvent(152, 0, 1144, 256)
    elseif gulliblesTravelsStatus == xi.questStatus.QUEST_COMPLETED then
        if
            evenmoreTravelsStatus == xi.questStatus.QUEST_AVAILABLE and
            player:getFameLevel(xi.fameArea.WINDURST) >= 7 and
            not player:needToZone()
        then
            player:startEvent(148, 0, 256, 0, 0, 35000)
        else
            player:startEvent(147)
        end
    else
        player:startEvent(143)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 148 and option == 1 then
        player:addQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.EVEN_MORE_GULLIBLES_TRAVELS)
    elseif csid == 150 then
        player:confirmTrade()
        player:delGil(35000)
        player:setCharVar('EVEN_MORE_GULLIBLES_PROGRESS', 1)
        player:setTitle(xi.title.EVEN_MORE_GULLIBLES_TRAVELS)
        npcUtil.giveKeyItem(player, xi.ki.TREASURE_MAP)
    elseif csid == 152 then
        player:setCharVar('EVEN_MORE_GULLIBLES_PROGRESS', 0)
        player:addFame(xi.fameArea.WINDURST, 30)
        player:completeQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.EVEN_MORE_GULLIBLES_TRAVELS)
    end
end

return entity
