-----------------------------------
-- Exotic Delicacies
-----------------------------------
-- Log ID: 9, Quest ID: 74
-- Flapano !pos 70 0 -13 256
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.EXOTIC_DELICACIES)

quest.reward =
{
    bayld = 500,
    item  = xi.item.PLATE_OF_FLAPANOS_PAELLA,
    exp   = 1000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getCharVar('Flapano_Odd_Even') == 0
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Flapano'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2860)
                end,
            },

            onEventFinish =
            {
                [2860] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end

                    player:setCharVar('Flapano_Odd_Even', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:getCharVar('Flapano_Odd_Even') == 0
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Flapano'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2863)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 3916, 5949, { 5954, 2 } }) then
                        return quest:progressEvent(2861)
                    elseif
                        npcUtil.tradeHas(trade, xi.item.PLATE_OF_BARNACLE_PAELLA) or
                        npcUtil.tradeHas(trade, xi.item.PLATE_OF_FLAPANOS_PAELLA)
                    then
                        return quest:progressEvent(2862)
                    end
                end,
            },

            onEventFinish =
            {
                [2861] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                        player:setCharVar('Flapano_Odd_Even', 0)
                    end
                end,

                [2863] = function(player, csid, option, npc)
                    player:setCharVar('Flapano_Odd_Even', 1)
                end,
            },
        },
    },
}

return quest
