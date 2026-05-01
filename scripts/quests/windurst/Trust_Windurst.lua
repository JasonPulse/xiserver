-----------------------------------
-- Trust: Windurst
-----------------------------------
-- !addquest 2 96
-- Wetata : !pos -23.825 2.533 -44.567 241
-- Kupipi : !pos 2 0.1 30 242
-----------------------------------
local heavensTowerID = zones[xi.zone.HEAVENS_TOWER]
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.TRUST_WINDURST)

quest.reward =
{
    keyItem = xi.ki.WINDURST_TRUST_PERMIT,
}

local function trustMemoryKupipi(player)
    local memories = 0

    if player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.THE_THREE_KINGDOMS) then
        memories = memories + 2
    end

    if player:hasCompletedMission(xi.mission.log_id.WINDURST, xi.mission.id.windurst.MOON_READING) then
        memories = memories + 8
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

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] =
            {
                onTrigger = function(player, npc)
                    local trustBastok = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK)
                    local trustSandoria = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA)

                    if
                        trustBastok == xi.questStatus.QUEST_AVAILABLE and
                        trustSandoria == xi.questStatus.QUEST_AVAILABLE
                    then
                        return quest:progressEvent(863)
                    elseif
                        trustBastok == xi.questStatus.QUEST_COMPLETED or
                        trustSandoria == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(867)
                    end
                end,
            },

            onEventFinish =
            {
                [863] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.GREEN_INSTITUTE_CARD)
                    end
                end,

                [867] = function(player, csid, option, npc)
                    if option == 2 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.GREEN_INSTITUTE_CARD)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.HEAVENS_TOWER] =
        {
            ['Kupipi'] =
            {
                onTrigger = function(player, npc)
                    local rank3 = player:getRank(player:getNation()) >= 3 and 1 or 0
                    local windurstFirstTrust = quest:getVar(player, 'Prog')

                    if
                        player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.TRUST_BASTOK) == xi.questStatus.QUEST_COMPLETED or
                        player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRUST_SANDORIA) == xi.questStatus.QUEST_COMPLETED
                    then
                        return quest:progressEvent(439, 0, 0, 0, trustMemoryKupipi(player), 0, 0, 0, rank3)
                    elseif windurstFirstTrust == 0 then
                        return quest:progressEvent(435, 0, 0, 0, trustMemoryKupipi(player), 0, 0, 0, rank3)
                    elseif windurstFirstTrust == 1 then
                        return quest:progressEvent(436):oncePerZone()
                    elseif windurstFirstTrust == 2 then
                        return quest:progressEvent(437)
                    end
                end,
            },

            onEventFinish =
            {
                [435] = function(player, csid, option, npc)
                    player:addSpell(xi.magic.spell.KUPIPI, { silentLog = true })
                    player:messageSpecial(heavensTowerID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.KUPIPI)
                    quest:setVar(player, 'Prog', 1)
                end,

                [437] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addTitle(xi.title.THE_TRUSTWORTHY)
                        player:delKeyItem(xi.ki.GREEN_INSTITUTE_CARD)
                        player:messageSpecial(heavensTowerID.text.KEYITEM_LOST, xi.ki.GREEN_INSTITUTE_CARD)
                        player:messageSpecial(heavensTowerID.text.CALL_MULTIPLE_ALTER_EGO)
                    end
                end,

                [439] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addSpell(xi.magic.spell.KUPIPI, { silentLog = true })
                        player:messageSpecial(heavensTowerID.text.YOU_LEARNED_TRUST, 0, xi.magic.spell.KUPIPI)
                        player:delKeyItem(xi.ki.GREEN_INSTITUTE_CARD)
                        player:messageSpecial(heavensTowerID.text.KEYITEM_LOST, xi.ki.GREEN_INSTITUTE_CARD)
                    end
                end,
            },
        },

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GREEN_INSTITUTE_CARD) then
                        return quest:progressEvent(864)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Wetata'] = quest:progressEvent(861),
        },
    },
}

return quest
