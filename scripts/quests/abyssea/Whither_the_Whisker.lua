-----------------------------------
-- Whither the Whisker
-----------------------------------
-- Log ID: 8, Quest ID: 37
-- Rahal : Abyssea - Vunkerl (F-4), entity 17666738
-- !addquest 8 37
-----------------------------------
-- Retail (bg-wiki "Whither the Whisker").
-- |Start=Rahal (A) (F-4), Abyssea - Vunkerl  |Previous= none  |Repeatable= no
-- |Item Reqs=Black Whisker
-- |Reward=800 Cruor, {{KI}} Crimson abyssite of celerity
--   1. Speak to Rahal (A) at (F-4).
--   2. Procure a Black Whisker, which drops from Slaughterous Smilodons
--      (northeast of Veridical Conflux #04 at (G-8)) or the Auction House.
--   3. Trade the Black Whisker to Rahal (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Rahal is 17666738; (17666738-16777216) = 889522,
-- 889522//4096 = 217 rem 738 -> Abyssea - Vunkerl, 0x010D92E2. `xi-dat events 217`
-- gives him 1017, 1018, 1020, 1021. Resolved with csidscan.py against
-- `xi-dat dialog 217`:
--   1017 -> 8130-8135  THE OFFER. 8131 "I am Rahal S Lebrart, Commander of the
--          Royal Knights of San d'Oria", 8134 "from the twisted visage of one of
--          these beasts sprouts a single jet-black whisker", closing on 8135
--          "Glean what knowledge you can of these creatures and that infernal
--          whisker". There is NO ${selection-lines} anywhere in the block, so
--          there is no accept option to test -- speaking to him starts it.
--   1018 -> 8129/8133/8135  the reminder, the request without the introduction.
--   1020 -> 8138-8143  THE TURN-IN. "That...that whisker! Could it truly be...!?"
--          / "We have them! Goddess's mercy, we finally have them!"
--   1021 -> 8144       the post-completion line.
--
-- ITEM: Black Whisker is the existing BLACK_WHISKER (3103).
-- KEY ITEM: Crimson abyssite of celerity is the existing
-- CRIMSON_ABYSSITE_OF_CELERITY (1386).
--
-- NOT REPEATABLE: bg-wiki's |Repeatable= is blank here, unlike the Abyssea
-- errand quests around it, and the reward is a one-off abyssite key item -- so
-- availability is not extended to COMPLETED the way it is in, say,
-- Shady_Business_Redux.lua.
-----------------------------------
local vunkerlID = zones[xi.zone.ABYSSEA_VUNKERL]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WHITHER_THE_WHISKER)

local cruorReward = 800

quest.reward =
{
    keyItem = xi.ki.CRIMSON_ABYSSITE_OF_CELERITY,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs= for this one.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Rahal'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1017)
                end,
            },

            onEventFinish =
            {
                [1017] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: bring him the whisker.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Rahal'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.BLACK_WHISKER) then
                        return quest:progressEvent(1020)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(1018)
                end,
            },

            onEventFinish =
            {
                [1020] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(vunkerlID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    -- Completed: his closing line (8144).
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Rahal'] = quest:event(1021):replaceDefault(),
        },
    },
}

return quest
