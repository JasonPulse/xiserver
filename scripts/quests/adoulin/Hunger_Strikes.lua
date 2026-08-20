-----------------------------------
-- Hunger Strikes
-----------------------------------
-- !addquest 9 76
-- Westerly Breeze : !pos 62 32 123 256
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.HUNGER_STRIKES)

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 500,
    exp      = 1000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] = quest:progressEvent(2530),

            onEventFinish =
            {
                [2530] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        -- MISSING ZONE WRAPPER, fixed -- same defect as The_Starving.lua, and the
        -- two are each other's prerequisite chain. These handlers sat at section
        -- level with no [xi.zone.WESTERN_ADOULIN] around them, and
        -- InteractionLookup:addContainer only keeps a section key when
        -- `validZoneTable[zoneId]` holds (interaction_lookup.lua:214) -- that table
        -- is keyed by NUMERIC zone ids, so 'Westerly_Breeze' and 'onEventFinish'
        -- were dropped at load. bg-wiki: "Trade a [[Wisdom Soup]] to him to
        -- complete the quest" -- that trade, the reminder line and the completion
        -- all silently did nothing, so the quest could be accepted and never
        -- finished.
        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.BOWL_OF_WISDOM_SOUP) then
                        return quest:progressEvent(2532)
                    elseif
                        trade:getItemCount() == 1 and
                        trade:getGil() == 0
                    then
                        local itemObj = trade:getItem(0)
                        local auctionCategory = itemObj:getAHCat()

                        if
                            auctionCategory >= xi.itemAHCategory.MEAT_EGGS and
                            auctionCategory <= xi.itemAHCategory.SWEETS
                        then
                            return quest:event(2533)
                        end
                    end
                end,

                onTrigger = quest:event(2531),
            },

            onEventFinish =
            {
                [2532] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()

                        xi.quest.setVar(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_STARVING, 'Timer', VanadielUniqueDay() + 1)
                    end
                end,

                [2533] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,
            },
        },
    },
}

return quest
