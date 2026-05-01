-----------------------------------
-- A Feather in One's Cap
-----------------------------------
-- Log ID: 2, Quest ID: 1
-- Baren-Moren !pos -66 -3 -148 238
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.A_FEATHER_IN_ONES_CAP)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.HAT_IN_HAND) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.WINDURST) >= 3 and
                not quest:getMustZone(player)
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Baren-Moren'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(75, 0, 842)
                end,
            },

            onEventFinish =
            {
                [75] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Baren-Moren'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(78, 0, 842)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { 842, 3 } }) then
                        return quest:progressEvent(79, 1500)
                    end
                end,
            },

            onEventFinish =
            {
                [79] = function(player, csid, option, npc)
                    player:addGil(xi.settings.main.GIL_RATE * 1500)
                    player:confirmTrade()
                    quest:setMustZone(player)

                    if quest:complete(player) then
                        player:addFame(xi.fameArea.WINDURST, 75)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and
                not quest:getMustZone(player)
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Baren-Moren'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Repeat') == 1 then
                        return quest:progressEvent(78, 0, 842)
                    else
                        return quest:progressEvent(75, 0, 842)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Repeat') == 1 and
                        npcUtil.tradeHas(trade, { { 842, 3 } })
                    then
                        return quest:progressEvent(79, 1500)
                    end
                end,
            },

            onEventFinish =
            {
                [75] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:setVar(player, 'Repeat', 1)
                    end
                end,

                [79] = function(player, csid, option, npc)
                    player:addGil(xi.settings.main.GIL_RATE * 1500)
                    player:confirmTrade()
                    player:addFame(xi.fameArea.WINDURST, 8)
                    quest:setVar(player, 'Repeat', 0)
                    quest:setMustZone(player)
                end,
            },
        },
    },
}

return quest
