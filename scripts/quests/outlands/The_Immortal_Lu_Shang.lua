-----------------------------------
-- The Immortal Lu Shang
-----------------------------------
-- Log ID: 5, Quest ID: 196
-- Irmilant !pos 3.78 9.54 56.21 247
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_IMMORTAL_LU_SHANG)

quest.reward =
{
    item     = 17386,
    fameArea = xi.fameArea.SELBINA_RABAO,
    fame     = 60,
    title    = xi.title.THE_IMMORTAL_FISHER_LU_SHANG,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasItem(xi.item.BROKEN_LU_SHANGS_FISHING_ROD)
        end,

        [xi.zone.RABAO] =
        {
            ['Irmilant'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(77)
                end,
            },

            onEventFinish =
            {
                [77] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.RABAO] =
        {
            ['Irmilant'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 720, xi.item.BROKEN_LU_SHANGS_FISHING_ROD, xi.item.LIGHT_CRYSTAL }) then
                        return quest:progressEvent(78)
                    end
                end,
            },

            onEventFinish =
            {
                [78] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
