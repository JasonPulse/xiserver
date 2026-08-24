-----------------------------------
-- The Angling Armorer
-----------------------------------
-- Log ID: 8, Quest ID: 6
-- Exoroche : Abyssea - La Theine (H-7), entity 17318634
-- !addquest 8 6
-----------------------------------
-- Retail (bg-wiki "The Angling Armorer").
-- |Start=Exoroche (A) (H-7), Abyssea - La Theine  |Fame=alth |FLevel=1
-- |Reward=40 ~ 320 Cruor depending on the item turned in  |Repeatable=Yes
--   1. Speak to Exoroche near Veridical Conflux #04.
--   2. "Trade Exoroche one of the following items for your reward.
--       Rusty Kunai for 40 Cruor. Rusty Spear for 80 Cruor.
--       Rusty Zaghnal for 120 Cruor. Rusty Shield for 320 Cruor."
--   3. "To repeat this quest, you do not need to speak to Exoroche again. Simply
--      trade him items from your inventory."
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Exoroche is 17318634 -> zone 132. Per-csid attribution
-- from his entry table's byte ranges:
--   188 -> 7987-7992  THE OFFER. 7989 "In La Theine there exist four ponds",
--          7991 "${item-plural: 0[2]}, ${item-plural: 1[2]}, ${item-plural: 2[2]},
--          and ${item-plural: 3[2]}..." -- the four rusty items are rendered from
--          the block's own data[], which is why this fires bare.
--   186 -> 7989/7991/7992  the reminder, the item list without the preamble.
--   187 -> 7993-7995  THE TURN-IN. 7993 "you've brought me ${article}
--          ${item-article: 0[2]}", 7995 "Should you fish up any more equipment, I
--          ask you to bring them to me with all haste."
--
-- The traded item id is passed to 187 because 7993 renders it from a param.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_ANGLING_ARMORER)

-- bg-wiki's exact table. Values are Cruor.
local payouts =
{
    [xi.item.RUSTY_KUNAI]   = 40,
    [xi.item.RUSTY_SPEAR]   = 80,
    [xi.item.RUSTY_ZAGHNAL] = 120,
    [xi.item.RUSTY_SHIELD]  = 320,
}

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

--- Which of the four he was handed, or nil for anything else.
local tradedItem = function(trade)
    for itemId, _ in pairs(payouts) do
        if npcUtil.tradeHasExactly(trade, itemId) then
            return itemId
        end
    end

    return nil
end

--- Trading works identically once accepted and after completion, since bg-wiki says
--- repeats need no new conversation.
local turnIn = function(player, npc, trade)
    local itemId = tradedItem(trade)

    if itemId == nil then
        return
    end

    quest:setVar(player, 'Turnin', itemId)

    return quest:progressEvent(187, itemId)
end

local payOut = function(player, csid, option, npc)
    local itemId = quest:getVar(player, 'Turnin')
    local cruor  = payouts[itemId]

    quest:setVar(player, 'Turnin', 0)

    if cruor == nil then
        return
    end

    -- bg-wiki: "You may also receive a random Evolith as an added reward when
    -- trading one of these items in to Exoroche." No rate is published, so the
    -- shared roll rate is reused rather than invented separately.
    xi.abyssea.questReward(player, cruor, { xi.item.EVOLITH })
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Exoroche'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(188)
                end,
            },

            onEventFinish =
            {
                [188] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Exoroche'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(186)
                end,

                onTrade = turnIn,
            },

            onEventFinish =
            {
                [187] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, csid, option, npc)
                    end
                end,
            },
        },
    },

    -- Repeatable, and deliberately trade-only: "you do not need to speak to
    -- Exoroche again."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Exoroche'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(186)
                end,

                onTrade = turnIn,
            },

            onEventFinish =
            {
                [187] = payOut,
            },
        },
    },
}

return quest
