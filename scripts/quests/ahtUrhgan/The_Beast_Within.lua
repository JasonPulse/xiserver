-----------------------------------
-- The Beast Within
-----------------------------------
-- Log ID: 6, Quest ID: 40
-- Waoud : Aht Urhgan Whitegate (J-10)
-----------------------------------
-- BLU Genkai 4 — raises BLU cap to 75. Retail: farm Blue Mage's
-- Testimony, solo duel Raubahn in Jade Sepulcher. Simplified for
-- 4-player server: trade testimony to Waoud → complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.THE_BEAST_WITHIN)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.BLU and
                player:getMainLvl() >= 66
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Waoud'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.BLUE_MAGES_TESTIMONY) then
                        return quest:progressEvent(160)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:progressEvent(161)
                end,
            },

            onEventFinish =
            {
                [160] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                    quest:complete(player)
                end,

                [161] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },
}

return quest
