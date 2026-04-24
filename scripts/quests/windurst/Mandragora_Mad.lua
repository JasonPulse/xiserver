-----------------------------------
-- Mandragora Mad
-----------------------------------
-- Log ID: 2, Quest ID: 34
-- Yoran-Oran !pos -109.987 -14 203.338 239
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.MANDRAGORA_MAD)

local tradeTable =
{
    [xi.item.CORNETTE]                 = { event = 251, gil =  200, fame = 10 },
    [xi.item.PINCH_OF_YUHTUNGA_SULFUR] = { event = 252, gil =  250, fame = 25 },
    [xi.item.THREE_LEAF_MANDRAGORA_BUD] = { event = 253, gil = 1200, fame = 50 },
    [xi.item.FOUR_LEAF_MANDRAGORA_BUD] = { event = 254, gil =  120, fame = 10 },
    [xi.item.SNOBBY_LETTER]            = { event = 255, gil = 5500, fame = 100 },
}

local function findTradeEntry(trade)
    for itemId, entry in pairs(tradeTable) do
        if npcUtil.tradeHas(trade, itemId, true) then
            return itemId, entry
        end
    end

    return nil, nil
end

local function completeEventHandler(entry)
    return function(player, csid, option, npc)
        quest.reward =
        {
            fame     = entry.fame,
            fameArea = xi.fameArea.WINDURST,
            gil      = xi.settings.main.GIL_RATE * entry.gil,
        }

        if quest:complete(player) then
            player:confirmTrade()
        end
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(249)
                end,
            },

            onEventFinish =
            {
                [249] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WALLS] =
        {
            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(256)
                end,

                onTrade = function(player, npc, trade)
                    local _, entry = findTradeEntry(trade)
                    if entry then
                        return quest:progressEvent(entry.event, xi.settings.main.GIL_RATE * entry.gil)
                    end

                    return quest:progressEvent(250)
                end,
            },

            onEventFinish =
            {
                [251] = completeEventHandler(tradeTable[xi.item.CORNETTE]),
                [252] = completeEventHandler(tradeTable[xi.item.PINCH_OF_YUHTUNGA_SULFUR]),
                [253] = completeEventHandler(tradeTable[xi.item.THREE_LEAF_MANDRAGORA_BUD]),
                [254] = completeEventHandler(tradeTable[xi.item.FOUR_LEAF_MANDRAGORA_BUD]),
                [255] = completeEventHandler(tradeTable[xi.item.SNOBBY_LETTER]),
            },
        },
    },
}

return quest
