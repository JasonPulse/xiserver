-----------------------------------
-- Area: Windurst Woods
--  NPC: Apururu
-- Involved in Quests: The Kind Cardian, Can Cardians Cry?
-- !pos -11 -2 13 241
-----------------------------------
local ID = zones[xi.zone.WINDURST_WOODS]
-----------------------------------
---@type TNpcEntity
local entity = {}

local trustMemory = function(player)
    local memories = 0
    -- 2 - Saw him at the start of the game
    if player:getNation() == xi.nation.WINDURST then
        memories = memories + 2
    end

    -- 4 - WONDER_WANDS
    if player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.WONDER_WANDS) then
        memories = memories + 4
    end

    -- 8 - THE_TIGRESS_STIRS
    if player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_TIGRESS_STIRS) then
        memories = memories + 8
    end

    -- 16 - I_CAN_HEAR_A_RAINBOW
    if player:hasCompletedQuest(xi.questLog.WINDURST, xi.quest.id.windurst.I_CAN_HEAR_A_RAINBOW) then
        memories = memories + 16
    end

    -- 64 - MOON_READING
    if player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.MOON_READING) then
        memories = memories + 64
    end

    return memories
end

entity.onTrade = function(player, npc, trade)
    -- THE KIND CARDIAN
    if
        player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_KIND_CARDIAN) == xi.questStatus.QUEST_ACCEPTED and
        npcUtil.tradeHas(trade, xi.item.TEN_OF_CUPS_CARD)
    then
        player:startEvent(397)
    end
end

entity.onTrigger = function(player, npc)
    local kindCardian = player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_KIND_CARDIAN)
    local kindCardianCS = player:getCharVar('theKindCardianVar')

    -- THE KIND CARDIAN
    if kindCardian == xi.questStatus.QUEST_ACCEPTED then
        if kindCardianCS == 0 then
            player:startEvent(392)
        elseif kindCardianCS == 1 then
            player:startEvent(393)
        elseif kindCardianCS == 2 then
            player:startEvent(398)
        end

    -- TRUST
    elseif
        player:hasKeyItem(xi.ki.WINDURST_TRUST_PERMIT) and
        not player:hasSpell(xi.magic.spell.AJIDO_MARUJIDO)
    then
        local rank6 = player:getRank(player:getNation()) >= 6 and 1 or 0

        player:startEvent(866, 0, 0, 0, trustMemory(player), 0, 0, 0, rank6)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    -- THE KIND CARDIAN
    if csid == 392 and option == 1 then
        player:setCharVar('theKindCardianVar', 1)
    elseif csid == 397 then
        player:delKeyItem(xi.ki.TWO_OF_SWORDS)
        player:setCharVar('theKindCardianVar', 2)
        player:addFame(xi.fameArea.WINDURST, 30)
        player:confirmTrade()

    -- TRUST
    elseif csid == 866 and option == 2 then
        player:addSpell(xi.magic.spell.AJIDO_MARUJIDO, { silentLog = true })
        player:messageSpecial(ID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.AJIDO_MARUJIDO)
    end
end

return entity
