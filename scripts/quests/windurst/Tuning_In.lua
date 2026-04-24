-----------------------------------
-- Tuning In
-----------------------------------
-- Log ID: 2, Quest ID: 90
-- Leepe-Hoppe !pos 13 -9 -197 238
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.TUNING_IN)

quest.reward =
{
    gil   = 4000,
    title = xi.title.FINE_TUNER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 4 and
                (player:getCurrentMission(xi.mission.log_id.COP) >= xi.mission.id.cop.DISTANT_BELIEFS or
                    player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_LAST_VERSE))
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Leepe-Hoppe'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(884, 0, 1696, 1697, 1698)
                end,
            },

            onEventFinish =
            {
                [884] = function(player, csid, option, npc)
                    quest:begin(player)
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
            ['Leepe-Hoppe'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(885, 0, 1696, 1697, 1698)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { 1696, 1697, 1698 }) then
                        return quest:progressEvent(886)
                    end
                end,
            },

            onEventFinish =
            {
                [886] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:tradeComplete()
                    end
                end,
            },
        },
    },
}

return quest
