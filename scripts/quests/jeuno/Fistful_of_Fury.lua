-----------------------------------
-- Fistful of Fury
-----------------------------------
-- Log ID: 3, Quest ID: 41
-- Vola !pos 43 3 -45 245
-----------------------------------
local lowerJeunoID = zones[xi.zone.LOWER_JEUNO]
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.FISTFUL_OF_FURY)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.NORG) >= 3 and
                player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.SILENCE_OF_THE_RAMS) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Vola'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(216)
                end,
            },

            onEventFinish =
            {
                [216] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Vola'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(215)
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.NUE_FANG, 1) and
                        trade:hasItemQty(xi.item.MORBOLGER_VINE, 1) and
                        trade:hasItemQty(xi.item.DODO_SKIN, 1) and
                        trade:getItemCount() == 3
                    then
                        return quest:progressEvent(213)
                    end
                end,
            },

            onEventFinish =
            {
                [213] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(lowerJeunoID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.BROWN_BELT)
                        return
                    end

                    player:addTitle(xi.title.BROWN_BELT)
                    player:addItem(xi.item.BROWN_BELT)
                    player:messageSpecial(lowerJeunoID.text.ITEM_OBTAINED, xi.item.BROWN_BELT)
                    player:addFame(xi.fameArea.NORG, 125)
                    player:tradeComplete()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
