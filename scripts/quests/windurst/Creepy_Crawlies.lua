-----------------------------------
-- Creepy Crawlies
-----------------------------------
-- Log ID: 2, Quest ID: 39
-- Illu Bohjaa
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.CREEPY_CRAWLIES)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    gil      = 600 * xi.settings.main.GIL_RATE,
    title    = xi.title.CRAWLER_CULLER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Illu_Bohjaa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(333, 0, xi.item.SPOOL_OF_SILK_THREAD, 938, 1156)
                end,
            },

            onEventFinish =
            {
                [333] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Illu_Bohjaa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(334, 0, xi.item.SPOOL_OF_SILK_THREAD, 938, 1156)
                end,

                onTrade = function(player, npc, trade)
                    if
                        npcUtil.tradeHas(trade, { { xi.item.SPOOL_OF_SILK_THREAD, 3 } }) or
                        npcUtil.tradeHas(trade, { { 1156, 3 } })
                    then
                        return quest:progressEvent(335, 600 * xi.settings.main.GIL_RATE, xi.item.SPOOL_OF_SILK_THREAD, 938, 1156)
                    end
                end,
            },

            onEventFinish =
            {
                [335] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
