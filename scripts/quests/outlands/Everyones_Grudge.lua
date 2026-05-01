-----------------------------------
-- Everyone's Grudge
-----------------------------------
-- Log ID: 5, Quest ID: 134
-- Magephaud (Norg)
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.EVERYONES_GRUDGE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getCharVar('EVERYONES_GRUDGE_KILLS') >= 1 and
                player:getFameLevel(xi.fameArea.NORG) >= 2
        end,

        [xi.zone.NORG] =
        {
            ['Magephaud'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(116, xi.item.GOLD_BEASTCOIN)
                end,
            },

            onEventFinish =
            {
                [116] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:setCharVar('EveryonesGrudgeStarted', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Magephaud'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(117, xi.item.GOLD_BEASTCOIN)
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.GOLD_BEASTCOIN, 3) and
                        trade:getItemCount() == 3
                    then
                        return quest:progressEvent(118, xi.item.GOLD_BEASTCOIN)
                    end
                end,
            },

            onEventFinish =
            {
                [118] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:tradeComplete()
                        player:addFame(xi.fameArea.NORG, 80)
                        npcUtil.giveKeyItem(player, xi.ki.TONBERRY_PRIEST_KEY)
                        player:setCharVar('EveryonesGrudgeStarted', 0)
                        player:addTitle(xi.title.HONORARY_DOCTORATE_MAJORING_IN_TONBERRIES)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Magephaud'] = quest:progressEvent(119),
        },
    },
}

return quest
