-----------------------------------
-- Mithran Delicacies
-----------------------------------
-- Log ID: 4, Quest ID: 97
-- Lourdaude : Carpenters' Landing (verified in npc_list.sql)
-- Retail: trade 1x Muddy Siredon + 100 gil → Blackened Muddy Siredon.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MITHRAN_DELICACIES)

quest.reward =
{
    fame     = 10,
    fameArea = xi.fameArea.OTHER_AREAS,
    item     = xi.item.BLACKENED_MUDDY_SIREDON,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.CARPENTERS_LANDING] =
        {
            ['Lourdaude'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { xi.item.MUDDY_SIREDON, gil = 100 }) then
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
