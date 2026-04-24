-----------------------------------
-- Elder Memories
-----------------------------------
-- Log ID: 4, Quest ID: 24
-- Isacio !pos -54 -1 -44 248
-----------------------------------
local selbinaID = zones[xi.zone.SELBINA]
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ELDER_MEMORIES)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.THE_OLD_LADY) == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.SELBINA] =
        {
            ['Isacio'] =
            {
                onTrigger = function(player, npc)
                    if player:getMainLvl() >= xi.settings.main.SUBJOB_QUEST_LEVEL then
                        return quest:progressEvent(111, xi.item.MAGICKED_SKULL)
                    else
                        return quest:progressEvent(119)
                    end
                end,
            },

            onEventFinish =
            {
                [111] = function(player, csid, option, npc)
                    if option == 40 then
                        quest:begin(player)
                        quest:setVar(player, 'Prog', 1)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.SELBINA] =
        {
            ['Isacio'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GILGAMESHS_INTRODUCTORY_LETTER) then
                        return quest:progressEvent(117)
                    end

                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 then
                        return quest:progressEvent(114, xi.item.MAGICKED_SKULL)
                    elseif prog == 2 then
                        return quest:progressEvent(114, xi.item.DAMSELFLY_WORM)
                    elseif prog == 3 then
                        return quest:progressEvent(114, xi.item.CRAB_APRON)
                    end
                end,

                onTrade = function(player, npc, trade)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 and npcUtil.tradeHas(trade, xi.item.MAGICKED_SKULL) then
                        return quest:progressEvent(115, xi.item.DAMSELFLY_WORM)
                    elseif prog == 2 and npcUtil.tradeHas(trade, xi.item.DAMSELFLY_WORM) then
                        return quest:progressEvent(116, xi.item.CRAB_APRON)
                    elseif prog == 3 and npcUtil.tradeHas(trade, xi.item.CRAB_APRON) then
                        return quest:progressEvent(117)
                    end
                end,
            },

            onEventFinish =
            {
                [115] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 2)
                end,

                [116] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 3)
                end,

                [117] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:unlockJob(0)
                    player:messageSpecial(selbinaID.text.SUBJOB_UNLOCKED)
                    quest:setVar(player, 'Prog', 0)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SELBINA] =
        {
            ['Isacio'] = quest:progressEvent(118),
        },
    },
}

return quest
