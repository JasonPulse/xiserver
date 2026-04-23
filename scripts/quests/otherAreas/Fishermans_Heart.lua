-----------------------------------
-- Fisherman's Heart
-----------------------------------
-- Log ID: 4, Quest ID: 11
-- Katsunaga : Mhaura pier (verified in npc_list.sql)
-- Retail: trade Gugru Tuna for fishing history readout. Simplified for
-- private server: accept + trade Gugru Tuna → immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FISHERMANS_HEART)

quest.reward =
{
    fame     = 10,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MHAURA] =
        {
            ['Katsunaga'] =
            {
                onTrade = function(player, npc, trade)
                    -- GUGRU_TUNA_1 (4480) or GUGRU_TUNA_2 (5805)
                    if
                        npcUtil.tradeHasExactly(trade, xi.item.GUGRU_TUNA_1) or
                        npcUtil.tradeHasExactly(trade, xi.item.GUGRU_TUNA_2)
                    then
                        return quest:progressEvent(100)
                    end
                end,
            },

            onEventFinish =
            {
                [100] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
