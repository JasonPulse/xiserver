-----------------------------------
-- Unbreak His Heart
-----------------------------------
-- Log ID: 8, Quest ID: 4
-- Joulet    : Abyssea - La Theine (H-7), entity 17318625
-- Gallijaux : Abyssea - La Theine (L-12), entity 17318638
-- !addquest 8 4
-----------------------------------
-- Retail (bg-wiki "Unbreak His Heart").
-- |Start=Joulet (A) (H-7), Abyssea - La Theine  |Fame=alth |FLevel=1
-- |Reward=120 Cruor  |Repeatable=Yes
--   1. Speak to Joulet at (H-7), Veridical Conflux #04.
--   2. "Offer to mend the fishing rod. He will give you a Broken Willow Fishing
--      Rod."
--   3. "Either repair the rod with a Light Crystal (Woodworking Level 10 cap), or
--      purchase one by other means."
--   4. "Trade a Willow Fishing Rod to Gallijaux at (L-12), Veridical Conflux #06."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Joulet 173 -> 7947-7957  THE OFFER. 7950 is a THREE-way menu, "Nothing. / Cheer
--          him up with a jest. / Offer to mend the fishing rod.", so the accepting
--          option is the third line, index 2. 7953 "Here is the
--          ${item-singular: 0[2]} that requires attention" is the broken rod, whose
--          id the block supplies from its own data[]. 7957 is the repeat line,
--          "Yet another fishing rod has fallen victim to my brother's ineptitude".
--   Joulet 171 -> 7955       the reminder, "please see it delivered safely to my
--          brother, Gallijaux."
--   Joulet 172 -> 7956       his flavour line about his brother breaking rods.
--   Gallijaux 174 -> 7960-7962  THE TURN-IN. 7960 "this is the
--          ${item-singular: 0[2]} I had sent to be repaired!"
--   Gallijaux 175 -> 7959    waiting, "Why is it taking so long to mend a simple
--          fishing rod?"
--   Gallijaux 176 -> 7963    his post-completion line.
--
-- The repaired rod is ordinary Woodworking, so nothing here crafts it: the quest
-- hands out the broken rod and accepts the finished one.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNBREAK_HIS_HEART)

local cruorReward = 120

-- 7950's third line, zero-indexed.
local optionMend = 2

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Joulet'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(173)
                end,
            },

            onEventFinish =
            {
                [173] = function(player, csid, option, npc)
                    -- The other two lines are declining and telling him a joke;
                    -- neither starts the quest.
                    if option ~= optionMend then
                        return
                    end

                    quest:begin(player)
                    npcUtil.giveItem(player, xi.item.BROKEN_WILLOW_FISHING_ROD)
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
            ['Joulet'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(171)
                end,
            },

            ['Gallijaux'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(175)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.WILLOW_FISHING_ROD) then
                        return quest:progressEvent(174, xi.item.WILLOW_FISHING_ROD)
                    end
                end,
            },

            onEventFinish =
            {
                [174] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest. Physically
    -- exiting the zone is required, not just logging off."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Joulet'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:event(172)
                    end

                    -- He has only 171/172/173; the offer csid is reused for
                    -- repeats, which is what 7957 ("Yet another fishing rod has
                    -- fallen victim...") inside 173 is there for.
                    return quest:progressEvent(173)
                end,
            },

            ['Gallijaux'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(176)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.WILLOW_FISHING_ROD) then
                        return quest:progressEvent(174, xi.item.WILLOW_FISHING_ROD)
                    end
                end,
            },

            onEventFinish =
            {
                [173] = function(player, csid, option, npc)
                    if option ~= optionMend then
                        return
                    end

                    npcUtil.giveItem(player, xi.item.BROKEN_WILLOW_FISHING_ROD)
                end,

                [174] = function(player, csid, option, npc)
                    xi.abyssea.questReward(player, cruorReward, nil)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNBREAK_HIS_HEART)
                end,
            },
        },
    },
}

return quest
