-----------------------------------
-- Don't Forget the Antidote
-----------------------------------
-- Log ID: 5, Quest ID: 192
-- Edigey (Rabao)
-----------------------------------
local rabaoID = zones[xi.zone.RABAO]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.DONT_FORGET_THE_ANTIDOTE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SELBINA_RABAO) >= 4
        end,

        [xi.zone.RABAO] =
        {
            ['Edigey'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2, 0, xi.item.VIAL_OF_DESERT_VENOM)
                end,
            },

            onEventFinish =
            {
                [2] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        player:setCharVar('DontForgetAntidoteVar', 1)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.RABAO] =
        {
            ['Edigey'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.DONT_FORGET_THE_ANTIDOTE) == xi.questStatus.QUEST_ACCEPTED then
                        return quest:progressEvent(3, 0, xi.item.VIAL_OF_DESERT_VENOM)
                    else
                        return quest:progressEvent(5, 0, xi.item.VIAL_OF_DESERT_VENOM)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.VIAL_OF_DESERT_VENOM, 1) and
                        trade:getItemCount() == 1
                    then
                        return quest:progressEvent(4, 0, xi.item.VIAL_OF_DESERT_VENOM)
                    end
                end,
            },

            onEventFinish =
            {
                [4] = function(player, csid, option, npc)
                    if player:getCharVar('DontForgetAntidoteVar') == 1 then
                        player:setCharVar('DontForgetAntidoteVar', 0)
                        player:tradeComplete()
                        player:addTitle(xi.title.DESERT_HUNTER)
                        player:addItem(xi.item.DOTANUKI)
                        player:messageSpecial(rabaoID.text.ITEM_OBTAINED, xi.item.DOTANUKI)
                        quest:complete(player)
                        player:addFame(xi.fameArea.SELBINA_RABAO, 60)
                    else
                        player:tradeComplete()
                        npcUtil.giveCurrency(player, 'gil', 1800)
                        player:addFame(xi.fameArea.SELBINA_RABAO, 30)
                    end
                end,
            },
        },
    },
}

return quest
