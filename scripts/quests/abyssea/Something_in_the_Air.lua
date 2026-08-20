-----------------------------------
-- Something in the Air
-----------------------------------
-- Log ID: 8, Quest ID: 44
-- Yoran-Oran : Abyssea - Attohwa (G-10), entity 17658615
-- Gasponia   : Abyssea - Attohwa (F-8)/(F-9), entities 17658539-17658568
-- !addquest 8 44
-----------------------------------
-- Retail (bg-wiki "Something in the Air").
-- |Start=Yoran-Oran (A), Abyssea - Attohwa  |Reward=Cura II (Scroll)
--   1. Speak to Yoran-Oran (A) in Abyssea - Attohwa at (G-10).
--   2. Examine the Gasponia targetable flowers in the vicinity of (F-8)/(F-9)
--      until you receive a Gasponia stamen. They are near Veridical Conflux #00.
--   3. Speak to Yoran-Oran to finish the quest and receive your reward.
--
-- CSIDS DECODED, NOT GUESSED. Yoran-Oran is 17658615 (zone 215 idx 759). He
-- carries several quests; csidscan.py against `xi-dat dialog 215` separates them,
-- and THIS one is the 348-351 block -- the air-contamination hypothesis, which is
-- what the quest is named for:
--   348 -> 8153-8170  THE OFFER. 8157 "I believe that the very air we
--          breathe-ethy has been contaminated!", 8163 "Something to the west of
--          here is spewing vile poison-ethy into the air!", and 8166 is the
--          accept prompt: "Got it? ${selection-lines} Yep-ethy. / Not
--          exactly-ethy." -- the affirmative is FIRST, so OPTION 0 ACCEPTS, and
--          8168 is the decline. 8169 states the task: "you must go west-ethy...
--          we need-ethy concrete scientific evidence-ethy!"
--   349 -> 8169/8170  the reminder, the task without the hypothesis.
--   350 -> 8173-8180  THE TURN-IN. "You're back! Well? What did you find-ethy?"
--          / "Why, this is...!"
--   351 -> 8179/8180  the post-completion lines.
-- The later 352+ block (8181-8191) is a DIFFERENT quest on the same NPC -- it
-- analyses the stamen and sends you back to inject a counteragent -- so it is
-- deliberately untouched here.
--
-- THE GASPONIA are thirty entities (17658539-17658568) and `xi-dat events 215`
-- shows none of them owns a single csid, which is why examining one is handled
-- with plain messages: 8171 "Before you blooms a large flower, its vivid
-- markings identifying it as clearly poisonous." and, when it yields, 8172
-- "Something falls to the ground beside your feet..." Neither carries a
-- ${prompt}. bg-wiki's wording is "examine... UNTIL you receive a Gasponia
-- stamen", i.e. it is a chance per examine rather than a guaranteed drop; the
-- rate is not published, so a flat chance is used and flagged as the one
-- unverified number in this file.
--
-- KEY ITEM: Gasponia stamen is the existing GASPONIA_STAMEN (1622).
-- REWARD: bg-wiki |Reward=Cura II (Scroll) -> SCROLL_OF_CURA_II (5082).
-----------------------------------
local attohwaID = zones[xi.zone.ABYSSEA_ATTOHWA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SOMETHING_IN_THE_AIR)

-- Unpublished; bg-wiki only says "until you receive".
local stamenChance = 35

quest.reward =
{
    item = xi.item.SCROLL_OF_CURA_II,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(348)
                end,
            },

            onEventFinish =
            {
                [348] = function(player, csid, option, npc)
                    -- 8166: 0 "Yep-ethy.", 1 "Not exactly-ethy."
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: search the gasponia west of camp for a stamen.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Gasponia'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GASPONIA_STAMEN) then
                        player:messageSpecial(attohwaID.text.GASPONIA_BLOOMS)
                        return
                    end

                    player:messageSpecial(attohwaID.text.GASPONIA_BLOOMS)

                    if math.random(100) <= stamenChance then
                        player:messageSpecial(attohwaID.text.GASPONIA_DROPS)
                        npcUtil.giveKeyItem(player, xi.ki.GASPONIA_STAMEN)
                    end
                end,
            },

            ['Yoran-Oran'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.GASPONIA_STAMEN) then
                        return quest:progressEvent(350)
                    end

                    return quest:event(349)
                end,
            },

            onEventFinish =
            {
                [350] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.GASPONIA_STAMEN)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ATTOHWA] =
        {
            ['Yoran-Oran'] = quest:event(351):replaceDefault(),
        },
    },
}

return quest
