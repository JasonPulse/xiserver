-----------------------------------
-- Dropping the Bomb
-----------------------------------
-- Log ID: 8, Quest ID: 55
-- Veit : Abyssea - Misareaux (H-4), entity 17662731
-- !addquest 8 55
-----------------------------------
-- Retail (bg-wiki "Dropping the Bomb").
-- |Start=Veit (A) (H-4), Abyssea - Misareaux  |Repeatable=Yes  |Fame=amis
-- |FLevel=3  |Item Reqs=Powder Casket  |Reward=1,200 Cruor
--   1. Speak to Veit (A) at (H-4), northeast of Conflux #5.
--   2. "He will request a Powder Casket. These can be obtained by defeating Brine
--      Crab, which are fished up in the nearby stream."
--   3. "After obtaining the Powder Casket, trade it back to Veit (A)."
--   4. "There is a chance he will not accept the casket because it has 'moisture'
--      inside. You will have to obtain another casket."
--   5. "The Versa Breeches will have a random augment on them."
--   "Zoning is required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED, AND THE HOLDER MATTERED HERE. Veit is 17662731 (zone
-- 216 idx 779); like the rest of the visible Misareaux NPCs his programs are stubs
-- and the real bytecode sits on holder 17662724 (0x010D8304), so csidmsg.py and
-- csidscan.py return nothing pointed at Veit and the HOLDER has to be scanned.
-- `xi-dat events 216` attributes 181-185 and 261 to him:
--   181 -> 8351-8363  THE OFFER. 8355 "Our forces had been transporting caskets of
--          gunpowder, when an angry swarm of the creatures fell upon us", 8357 is
--          the accept prompt: "Help retrieve the gunpowder? ${selection-lines}
--          Sure, it'll be a blast! / Nah, I've got better things to do." -- the
--          affirmative is the FIRST line, so OPTION 0 ACCEPTS, and 8359 is the
--          decline. 8360 "The attack reportedly took place as the cargo train was
--          fording the river" is the where, and 8362 foreshadows the moisture:
--          "the caskets would have been tightly sealed. However, that doesn't mean
--          they're impervious to the elements."
--   182 -> 8360-8363  the reminder, the directions without the preamble.
--   183 -> 8364-8368  THE TURN-IN, and it branches: 8364 "Let's open it up and see
--          whether the contents survived the ordeal...", then EITHER 8365 "Blast!
--          Moisture's gotten inside and spoiled the gunpowder! There must still be
--          kegs out there" OR 8366 "The gunpowder hasn't been spoiled by moisture!
--          Huzzah!" followed by 8367's reward.
--   184 -> 8369       his post-completion line.
--   185 -> 8370/8371  the repeat offer: "could I count on you to retrieve more
--          caskets of gunpowder?"
--   261 -> 8351-8353  his overheard panic before the quest is available.
--
-- THE MOISTURE BRANCH IS PARAM 0. 8365 and 8366 are two SEPARATE messages rather
-- than one ${choice}, so the event branches on a param rather than substituting --
-- the same shape A Ward to End All Wards uses for its three outcomes. The casket
-- itself is NOT event-supplied: unlike this zone's other quests, the holder's
-- data[] carries no 2954, and Veit's lines name "caskets of gunpowder" in plain
-- prose with no ${item...} placeholder anywhere, so there is nothing to pass.
--
-- ITEMS: Powder Casket is id 2954 and Versa Breeches id 11930; neither had an enum
-- name and both were added after checking the ids were unused.
--
-- ON THE "RANDOM AUGMENT": bg-wiki says the Versa Breeches come augmented but does
-- not publish the pool, so the breeches are granted unaugmented rather than with an
-- invented augment.
--
-- THE REJECTION RATE is not published on bg-wiki either -- it says only that
-- "there is a chance". An even chance is used, which keeps the retail failure mode
-- (you must go and fish another casket) without inventing a specific rate.
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DROPPING_THE_BOMB)

local cruorReward = 1200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_MISAREAUX,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes; 185 is his re-offer, and
    -- bg-wiki requires a zone in between.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                not quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Veit'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DROPPING_THE_BOMB) then
                        return quest:progressEvent(185)
                    end

                    return quest:progressEvent(181)
                end,
            },

            onEventFinish =
            {
                [181] = function(player, csid, option, npc)
                    -- 8357: 0 "Sure, it'll be a blast!", 1 "Nah, I've got better
                    -- things to do."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                end,

                [185] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DROPPING_THE_BOMB)
                end,
            },
        },
    },

    -- Accepted: fish caskets out of the stream until one is still dry.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Veit'] =
            {
                onTrade = function(player, npc, trade)
                    if not npcUtil.tradeHasExactly(trade, xi.item.POWDER_CASKET) then
                        return
                    end

                    -- 8365 spoiled / 8366 dry. He takes the casket either way.
                    local spoiled = math.random(1, 2) == 1

                    player:setLocalVar('BombSpoiled', spoiled and 1 or 0)

                    return quest:progressEvent(183, { [0] = spoiled and 0 or 1 })
                end,

                onTrigger = function(player, npc)
                    return quest:event(182)
                end,
            },

            onEventFinish =
            {
                [183] = function(player, csid, option, npc)
                    local spoiled = player:getLocalVar('BombSpoiled') == 1

                    player:confirmTrade()
                    player:setLocalVar('BombSpoiled', 0)

                    -- A spoiled casket is consumed but does not finish the quest;
                    -- 8365 sends you back out for another.
                    if spoiled then
                        return
                    end

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                        npcUtil.giveItem(player, xi.item.VERSA_BREECHES)
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.DROPPING_THE_BOMB)
                    end
                end,
            },
        },
    },

    -- Completed: 8369, the blasting operation goes ahead.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Veit'] = quest:event(184):replaceDefault(),
        },
    },
}

return quest
