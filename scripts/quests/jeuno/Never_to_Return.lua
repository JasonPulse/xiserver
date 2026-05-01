-----------------------------------
-- Never to Return
-----------------------------------
-- Log ID: 3, Quest ID: 14
-- Kurou-Morou !pos -4 -6 -28 245
-----------------------------------
local lowerJeunoID = zones[xi.zone.LOWER_JEUNO]
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.NEVER_TO_RETURN)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.JEUNO) >= 5 and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.YOUR_CRYSTAL_BALL) == xi.questStatus.QUEST_COMPLETED and
                player:getCharVar('QuestNeverToReturn_day') ~= VanadielUniqueDay()
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Kurou-Morou'] =
            {
                onTrigger = function(player, npc)
                    local prog = player:getCharVar('QuestNeverToReturn_prog')
                    if prog <= 2 then
                        return quest:progressEvent(204, math.random(1, 99))
                    else
                        return quest:progressEvent(202)
                    end
                end,
            },

            onEventFinish =
            {
                [202] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                        player:setCharVar('QuestNeverToReturn_prog', 0)
                        player:setCharVar('QuestNeverToReturn_day', 0)
                    end
                end,

                [204] = function(player, csid, option, npc)
                    if option == 0 then
                        player:incrementCharVar('QuestNeverToReturn_prog', 1)
                        player:setCharVar('QuestNeverToReturn_day', VanadielUniqueDay())
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
            ['Kurou-Morou'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.HORN_HAIRPIN, 1) and
                        trade:getItemCount() == 1
                    then
                        return quest:progressEvent(203)
                    end
                end,
            },

            onEventFinish =
            {
                [203] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(lowerJeunoID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.GARNET_RING)
                        return
                    end

                    npcUtil.giveCurrency(player, 'gil', 1200)
                    player:addItem(xi.item.GARNET_RING)
                    player:messageSpecial(lowerJeunoID.text.ITEM_OBTAINED, xi.item.GARNET_RING)
                    player:addFame(xi.fameArea.JEUNO, 30)
                    player:tradeComplete()
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
