-----------------------------------
-- Threadbare Tribulations
-----------------------------------
-- Log ID: 8, Quest ID: 42
-- Ponono : Abyssea - Attohwa (H-7), entity 17658613
-- !addquest 8 42
-----------------------------------
-- Retail (bg-wiki "Threadbare Tribulations").
-- |Start=Ponono (A) (H-7), Abyssea - Attohwa  |Repeatable=Yes
-- |Item Reqs=Amoeban Pseudopod x3
-- |Reward=200 Cruor, chance at one of the Empyrean Armor +1 Feet seals
--   1. Speak to Ponono (A) at (H-7), Veridical Conflux #08.
--   2. She asks for 3 Amoeban Pseudopods.
--   3. Trade them to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Ponono is 17658613 (zone 215 idx 757);
-- `xi-dat events 215` gives her 339, 340, 341, 342, resolved with csidscan.py
-- against `xi-dat dialog 215`:
--   339 -> 8132-8136  THE OFFER. 8134 "I mean to patch up their garments!... I
--          lack for the very-wery materials this task requires", 8135 names the
--          substitute (${item-plural: 0[2]}), and 8136 is the request itself:
--          "I would be ever so grateful if you could bring me ${number: 1} of
--          these ${item-given-plurality: 1[2], 0[2]}." Count is param 1, item is
--          param 0. There is NO ${selection-lines} in the block, so there is no
--          accept option to test -- speaking to her starts it.
--   340 -> 8136       the reminder, the request on its own.
--   341 -> 8137       THE TURN-IN. "Oh, they're absolutely beautiful! I can't
--          thank you enough! If you ever happen-wappen to come across
--          ${number: 1} more..." -- which is also the re-offer, matching
--          |Repeatable=Yes.
--   342 -> 8138/8139  her post-completion chatter.
--
-- ITEM: Amoeban Pseudopod is id 2641 (`item_basic` name `amoeban_pseudopod`,
-- sort name `amb._pseudopod`), which had no enum name and was added as
-- AMOEBAN_PSEUDOPOD after checking the id was unused.
--
-- REWARD: bg-wiki lists "200 Cruor" plus "Chance at one of the following
-- Empyrean Armor +1 Feet" seals, without publishing a rate.
--   * The four seals are verified against item_basic and are the FEET set, not
--     the head set An_Offer_You_Cant_Refuse.lua uses: Orison (3192), Raider's
--     (3195), Ferine (3198), Unkai (3201).
--   * The RATE is owner-supplied: 30% overall per turn-in, split evenly across
--     the four, i.e. 7.5% for any one specific seal. bg-wiki does not publish
--     this and it is not derivable from the DATs, so it is recorded here as an
--     owner decision rather than as decoded data -- the same footing as the
--     Elite Beret augment weighting in An_Offer_You_Cant_Refuse.lua.
-----------------------------------
local attohwaID = zones[xi.zone.ABYSSEA_ATTOHWA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THREADBARE_TRIBULATIONS)

local pseudopodCount = 3
local cruorReward    = 200

-- Empyrean Armor +1 FEET seals. Owner-supplied rate: 30% that any seal drops,
-- then an even split across the four (7.5% each overall).
local sealChance = 30

local feetSeals =
{
    xi.item.ORISON_SEAL_FEET,  -- White Mage
    xi.item.RAIDERS_SEAL_FEET, -- Thief
    xi.item.FERINE_SEAL_FEET,  -- Beastmaster
    xi.item.UNKAI_SEAL_FEET,   -- Samurai
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=Yes, and 8137 is her own re-offer line.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Ponono'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(339,
                        { [0] = xi.item.AMOEBAN_PSEUDOPOD, [1] = pseudopodCount })
                end,
            },

            onEventFinish =
            {
                [339] = function(player, csid, option, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THREADBARE_TRIBULATIONS) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THREADBARE_TRIBULATIONS)
                    else
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

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Ponono'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.AMOEBAN_PSEUDOPOD, pseudopodCount } }) then
                        return quest:progressEvent(341,
                            { [0] = xi.item.AMOEBAN_PSEUDOPOD, [1] = pseudopodCount })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(340,
                        { [0] = xi.item.AMOEBAN_PSEUDOPOD, [1] = pseudopodCount })
                end,
            },

            onEventFinish =
            {
                [341] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(attohwaID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))

                        -- One roll for whether a seal drops at all, then an even
                        -- pick among the four -- so at most one is ever granted.
                        if math.random(100) <= sealChance then
                            npcUtil.giveItem(player, feetSeals[math.random(#feetSeals)])
                        end
                    end
                end,
            },
        },
    },
}

return quest
