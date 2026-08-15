-----------------------------------
-- Collect Tarut Cards
-----------------------------------
-- Log ID: 3, Quest ID: 10
-- Chululu !pos -13 -6 -42 245
-----------------------------------
local lowerJeunoID = zones[xi.zone.LOWER_JEUNO]
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.COLLECT_TARUT_CARDS)

-- bg-wiki header for THIS quest: |Fame=Jeuno |FLevel=2 |Title= (empty).
-- Card Collector belongs to the FOLLOW-UP, All in the Cards, whose header reads
-- |Title=Card Collector -- and that file already grants it. Awarding it here too
-- handed the title out one quest early and duplicated it.
quest.reward =
{
    fameArea = xi.fameArea.JEUNO,
    fame     = 30,
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
                -- bg-wiki |FLevel=2. Was 3, i.e. gated one level too strictly --
                -- and this quest is the entry point for All in the Cards and
                -- Rubbish Day, so the whole Chululu line started late.
                player:getFameLevel(xi.fameArea.JEUNO) >= 2
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(28)
                end,
            },

            onEventFinish =
            {
                [28] = function(player, csid, option, npc)
                    if option == 0 then
                        local card = randomCard()

                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(lowerJeunoID.text.ITEM_CANNOT_BE_OBTAINED, card)
                        else
                            quest:begin(player)
                            player:addItem(card, 5)
                            player:messageSpecial(lowerJeunoID.text.ITEM_OBTAINED, card)
                        end
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
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(27)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { xi.item.TARUT_CARD_THE_FOOL, xi.item.TARUT_CARD_DEATH, xi.item.TARUT_CARD_THE_KING, xi.item.TARUT_CARD_THE_HERMIT }, true) then
                        return quest:progressEvent(200)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:tradeComplete()
                    end
                end,
            },
        },
    },
}

return quest
