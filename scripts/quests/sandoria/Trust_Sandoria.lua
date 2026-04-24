-----------------------------------
-- Trust: San d'Oria
-----------------------------------
-- !addquest 0 119
-- Gondebaud  : !pos 123.754 0.000 92.125 230
-- Excenmille : !pos -229.344 6.999 22.976 231
-----------------------------------
local northernSandyID = zones[xi.zone.NORTHERN_SAN_DORIA]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)

quest.reward =
{
    keyItem = xi.ki.SAN_DORIA_TRUST_PERMIT,
}

local function trustMemoryExcenmille(player)
    local memories = 0

    if player:hasKeyItem(xi.ki.BALLISTA_LICENSE) then
        memories = memories + 2
    end

    if player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.CLAWS_OF_THE_GRIFFON) then
        memories = memories + 8
    end

    if player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BLOOD_OF_HEROES) then
        memories = memories + 16
    end

    return memories
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 5 and
                xi.settings.main.ENABLE_TRUST_QUESTS == 1
        end,

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] =
            {
                onTrigger = function(player, npc)
                    local trustBastok = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)
                    local trustWindurst = player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)

                    if
                        trustBastok == xi.questStatus.QUEST_AVAILABLE and
                        trustWindurst == xi.questStatus.QUEST_AVAILABLE
                    then
                        return quest:progressEvent(3500)
                    elseif
                        trustBastok == xi.questStatus.QUEST_COMPLETED or
                        trustWindurst == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(3504)
                    end
                end,
            },

            onEventFinish =
            {
                [3500] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.RED_INSTITUTE_CARD)
                    end
                end,

                [3504] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.RED_INSTITUTE_CARD)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Excenmille'] =
            {
                onTrigger = function(player, npc)
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0
                    local sandoriaFirstTrust = quest:getVar(player, 'Prog')

                    if
                        player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK) == xi.questStatus.QUEST_COMPLETED or
                        player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST) == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(897, 0, 0, 0, trustMemoryExcenmille(player), 0, 0, 0, rank3)
                    elseif sandoriaFirstTrust == 0 then
                        return quest:progressEvent(893, 0, 0, 0, trustMemoryExcenmille(player), 0, 0, 0, rank3)
                    elseif sandoriaFirstTrust == 1 then
                        return quest:progressEvent(894):oncePerZone()
                    elseif sandoriaFirstTrust == 2 then
                        return quest:progressEvent(895)
                    end
                end,
            },

            onEventFinish =
            {
                [893] = function(player, csid, option, npc)
                    player:addSpell(xi.magic.spell.EXCENMILLE, { silentLog = true })
                    player:messageSpecial(northernSandyID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.EXCENMILLE)
                    quest:setVar(player, 'Prog', 1)
                end,

                [895] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addTitle(xi.title.THE_TRUSTWORTHY)
                        player:delKeyItem(xi.ki.RED_INSTITUTE_CARD)
                        player:messageSpecial(northernSandyID.text.KEYITEM_LOST, xi.ki.RED_INSTITUTE_CARD)
                        player:messageSpecial(northernSandyID.text.CALL_MULTIPLE_ALTER_EGO)
                    end
                end,

                [897] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addSpell(xi.magic.spell.EXCENMILLE, { silentLog = true })
                        player:messageSpecial(northernSandyID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.EXCENMILLE)
                        player:delKeyItem(xi.ki.RED_INSTITUTE_CARD)
                        player:messageSpecial(northernSandyID.text.KEYITEM_LOST, xi.ki.RED_INSTITUTE_CARD)
                    end
                end,
            },
        },

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.RED_INSTITUTE_CARD) then
                        return quest:progressEvent(3501)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Gondebaud'] = quest:progressEvent(3502),
        },
    },
}

return quest
