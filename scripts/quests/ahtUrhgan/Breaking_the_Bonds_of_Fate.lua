-----------------------------------
-- Breaking the Bonds of Fate
-----------------------------------
-- Log ID: 6, Quest ID: 41
-- Naja_Salaheem : Aht Urhgan Whitegate (I-10)
-----------------------------------
-- COR Genkai 4 — raises COR cap to 75. Retail: farm Corsair's Testimony,
-- Talacca Cove BCNM. Simplified for 4-player server: trade testimony to
-- Naja → complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.BREAKING_THE_BONDS_OF_FATE)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.WINDURST,
    title    = xi.title.MASTER_OF_CHANCE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainJob() == xi.job.COR and
                player:getMainLvl() >= 66
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Naja_Salaheem'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.CORSAIRS_TESTIMONY) then
                        return quest:progressEvent(170)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:progressEvent(171)
                end,
            },

            onEventFinish =
            {
                [170] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                    quest:complete(player)
                end,

                [171] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },
}

return quest
