-----------------------------------
-- Donate to Recycling
-----------------------------------
-- Log ID: 4, Quest ID: 16
-- Romeo !pos -11 -11 -6 248
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.DONATE_TO_RECYCLING)

quest.reward =
{
    fameArea = xi.fameArea.SELBINA_RABAO,
    item     = xi.item.WASTEBASKET,
    title    = xi.title.ECOLOGIST,
}

local tradeItems = { 16482, 16483, 16534, 17068, 17104 }

local function hasRequiredTrade(trade)
    for _, itemId in ipairs(tradeItems) do
        if npcUtil.tradeHas(trade, { { itemId, 5 } }) then
            return true
        end
    end

    return false
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.SELBINA] =
        {
            ['Romeo'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(20)
                end,
            },

            onEventFinish =
            {
                [20] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.SELBINA] =
        {
            ['Romeo'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(22)
                end,

                onTrade = function(player, npc, trade)
                    if hasRequiredTrade(trade) then
                        return quest:progressEvent(21)
                    end
                end,
            },

            onEventFinish =
            {
                [21] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
