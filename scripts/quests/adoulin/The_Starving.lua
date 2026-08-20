-----------------------------------
-- The Starving
-----------------------------------
-- !addquest 9 84
-- Westerly Breeze : !pos 62 32 123 256
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_STARVING)

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    exp      = 1000,
    bayld    = 500,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                quest:getVar(player, 'Timer') <= VanadielUniqueDay() and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 2
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] = quest:progressEvent(3005),

            onEventFinish =
            {
                [3005] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        -- MISSING ZONE WRAPPER, fixed. This section's contents used to sit at
        -- section level -- keyed ['Westerly_Breeze'] and onEventFinish directly --
        -- with no [xi.zone.WESTERN_ADOULIN] around them. InteractionLookup:addContainer
        -- iterates `for zoneId, secondLevel in pairs(section)` and keeps a key only
        -- if `validZoneTable[zoneId]` (interaction_lookup.lua:214); validZoneTable is
        -- keyed by NUMERIC zone ids, so the string keys were silently discarded and
        -- none of these handlers were ever registered. The Goblin Drink trade that
        -- bg-wiki gives as the completion step ("Trade him a Goblin Drink to
        -- complete the quest") could not fire, so the quest was uncompletable --
        -- and with it Always "more," Quoth the Ravenous, which this section is what
        -- arms. Section 1 above always had the wrapper, which is why the quest
        -- could still be accepted.
        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.BOTTLE_OF_GOBLIN_DRINK) then
                        return quest:progressEvent(3007)
                    elseif
                        trade:getItemCount() == 1 and
                        trade:getGil() == 0
                    then
                        local itemObj = trade:getItem(0)
                        local auctionCategory = itemObj:getAHCat()

                        if auctionCategory == xi.itemAHCategory.DRINKS then
                            return quest:event(3008)
                        else
                            return quest:event(3006)
                        end
                    else
                        return quest:event(3006)
                    end
                end,

                onTrigger = quest:event(3006),
            },

            onEventFinish =
            {
                [3007] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.quest.setMustZone(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.ALWAYS_MORE_QUOTH_THE_RAVENOUS)
                        xi.quest.setVar(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.ALWAYS_MORE_QUOTH_THE_RAVENOUS, 'Timer', VanadielUniqueDay() + 1)
                    end
                end,

                [3008] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,
            },
        },
    },
}

return quest
