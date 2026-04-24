-----------------------------------
-- The All-New C-2000
-----------------------------------
-- Log ID: 2, Quest ID: 24
-- Kopuro-Popuro !pos -0.037 -4.749 -22.589 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.THE_ALL_NEW_C_2000)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 80,
    gil      = 200,
    title    = xi.title.CARDIAN_TUTOR,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(285, 0, 856, 846, 4368)
                end,
            },

            onEventFinish =
            {
                [285] = function(player, csid, option, npc)
                    if option ~= 2 then
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

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kopuro-Popuro'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(288, 0, 856, 846, 4368)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 846, 856, 4368 }) then
                        return quest:progressEvent(292, xi.settings.main.GIL_RATE * 200)
                    else
                        return quest:progressEvent(288, 0, 856, 846, 4368)
                    end
                end,
            },

            onEventFinish =
            {
                [292] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
