-----------------------------------
-- All in the Cards
-----------------------------------
-- Log ID: 3, Quest ID: 166
-- Chululu !pos -13 -6 -42 245
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.ALL_IN_THE_CARDS)

-- bg-wiki header: |Fame=Jeuno |Title=Card Collector. fameArea was missing, and
-- giveReward only calls addFame when params['fameArea'] is set (npc_util.lua),
-- so this quest paid no fame at all despite the header naming Jeuno. The amount
-- comes from giveReward's own default of 30, matching sibling Collect Tarut Cards.
quest.reward =
{
    fameArea = xi.fameArea.JEUNO,
    gil      = 600,
    title    = xi.title.CARD_COLLECTOR,
}

local function randomCard()
    local rand = math.random(1, 4)

    if rand == 1 then
        return xi.item.TARUT_CARD_DEATH
    elseif rand == 2 then
        return xi.item.TARUT_CARD_THE_HERMIT
    elseif rand == 3 then
        return xi.item.TARUT_CARD_THE_KING
    else
        return xi.item.TARUT_CARD_THE_FOOL
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                -- bg-wiki header: |Fame=Jeuno |FLevel=5. Was 4.
                player:getFameLevel(xi.fameArea.JEUNO) >= 5 and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.COLLECT_TARUT_CARDS) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10110)
                end,
            },

            onEventFinish =
            {
                [10110] = function(player, csid, option, npc)
                    if option == 0 then
                        if npcUtil.giveItem(player, { { randomCard(), 5 } }) then
                            quest:begin(player)
                            player:setCharVar('AllInTheCards_date', JstMidnight())
                            player:setLocalVar('Cardstemp', 1)
                        end
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

        [xi.zone.LOWER_JEUNO] =
        {
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    if player:getLocalVar('Cardstemp') ~= 0 then
                        return
                    end

                    local cdate = player:getCharVar('AllInTheCards_date')

                    if cdate >= GetSystemTime() then
                        return quest:progressEvent(10111)
                    elseif cdate == 0 then
                        return quest:progressEvent(10113)
                    else
                        return quest:progressEvent(10112)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { xi.item.TARUT_CARD_THE_FOOL, xi.item.TARUT_CARD_DEATH, xi.item.TARUT_CARD_THE_KING, xi.item.TARUT_CARD_THE_HERMIT }, true) then
                        return quest:progressEvent(10114)
                    end
                end,
            },

            onEventFinish =
            {
                [10111] = function(player, csid, option, npc)
                    player:setLocalVar('Cardstemp', 1)
                end,

                [10112] = function(player, csid, option, npc)
                    if option == 0 then
                        if npcUtil.giveItem(player, { { randomCard(), 5 } }) then
                            player:setCharVar('AllInTheCards_date', JstMidnight())
                            player:setLocalVar('Cardstemp', 1)
                        end
                    end
                end,

                [10113] = function(player, csid, option, npc)
                    if option == 0 then
                        if npcUtil.giveItem(player, { { randomCard(), 5 } }) then
                            player:setCharVar('AllInTheCards_date', JstMidnight())
                            player:setLocalVar('Cardstemp', 1)
                        end
                    end
                end,

                [10114] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                        player:setCharVar('AllInTheCards_date', 0)
                    end
                end,
            },
        },
    },
}

return quest
