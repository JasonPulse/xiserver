-----------------------------------
-- A Furious Finale
-----------------------------------
-- Log ID: 3, Quest ID: 99
-- Laila : Upper Jeuno (G-7), default event 10120
-----------------------------------
-- DNC Genkai quest — raises DNC level cap to 75. Retail required
-- Dancer's Testimony, fight Maat-analog on DNC.
-- Simplified for 4-player server: trade Dancer's Testimony → complete.
-- Level cap handled server-side via quest-completion check.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.A_FURIOUS_FINALE)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.DNC and
                player:getMainLvl() >= 66
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.DANCERS_TESTIMONY) then
                        return quest:progressEvent(10124)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:progressEvent(10123)
                end,
            },

            onEventFinish =
            {
                [10123] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,

                [10124] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
