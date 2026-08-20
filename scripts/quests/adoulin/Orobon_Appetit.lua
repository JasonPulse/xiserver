-----------------------------------
-- Orobon Appetit
-----------------------------------
-- Log ID: 9, Quest ID: 59
-- Nestroh : Foret de Hennetiel (H-9), near Bivouac #3, entity 17850927
-- !addquest 9 59
-----------------------------------
-- Retail (bg-wiki "Orobon Appetit").
-- |Start=Nestroh, Foret de Hennetiel - (H-9)  |Fame=Adoulin
-- |Quest Reqs=A fishing rod  |Reward=Paresis resilience
--   1. Talk to Nestroh, near Bivouac #3, to accept the quest.
--   2. "Fish up Delectable Orobon, which drop a guaranteed Delectable Orobon Steak
--      upon defeat."
--      "The steak will be chosen randomly from one of five different cuts: tail,
--      stomach, cheeks, back, or liver."
--   3. Return and trade the Orobon steak to Nestroh.
--      "Only a liver cut will sate Nestroh's hunger. All other cuts will be
--      rejected, and it is possible to receive multiple undesired cuts."
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Nestroh is 17850927 -> zone 262 idx 559 (0x0110622F). `xi-dat events 262` gives him
-- 2570-2575. The dumped dialog file labelled zone N holds zone N-1's text for the
-- Adoulin FIELD zones, so Foret's text is in the file labelled 263; the offset is
-- pinned by this repo's own known-correct id (Foret_de_Hennetiel/IDs.lua
-- WAYPOINT_ATTUNED = 7688 resolves in dump 263). Read against 263:
--   2570 -> 7537       his brush-off: "I'm sick of turning away all these pretenders.
--          Not a one with ${keyitem-article: 0[2]}!" -- the Pioneer's badge, the same
--          registration gate Veldeth uses in It Never Goes Out of Style.
--   2571 -> 7538-7541  THE OFFER. 7539 "I've been trying all day to stare these
--          out-of-this-world Delectable Orobons i[nto submission]", 7540 "I want to
--          taste succulent orobon flesh!", and 7541 "if for some reason you happen to
--          find ${article} ${item-article: 0[2]}, could you stop by h[ere]" -- the
--          steak is param 0. No ${selection-lines}, so speaking to him starts it.
--   2572 -> 7542       the reminder: "Well? Did you find ${article}
--          ${item-article: 0[2]}?"
--   2573 -> 7543-7551  THE WRONG CUT. 7543 "this meat is from the ${choice: 0}
--          [liver/cheeks/stomach/back/tail] of the creature", one tasting reaction per
--          cut (7545-7548), then 7550 "Delightful, to be sure, but not the
--          'out-of-this-world' bounty I was expecting." 7551 is the duplicate-cut
--          line bg-wiki quotes as trivia: "I know I've already tried this part, but
--          who am I to say no to a good thing!"
--   2574 -> 7543/7544 + 7552-7560  THE LIVER. 7552 "Unbelievable! The strong aroma
--          and ambrosial flavor!", 7554 "Nestroh practically shoves the meat down your
--          throat!", 7557 "it might have just been all the toxins that had accumulated
--          in the liver", and 7559 is the reward's in-fiction origin: "the guy
--          mentioned something about being more resistant to paresis thanks to eating
--          that delightful dish."
--   2575 -> 7561       his post-completion line.
--
-- LIVER IS CUT 0. 7543's ${choice: 0} enumerates the cuts in the order
-- [liver/cheeks/stomach/back/tail], so index 0 is the liver -- the one bg-wiki says is
-- the only one that satisfies him. The cut is therefore param 0 on both turn-in csids,
-- and which csid fires is decided by whether the roll came up 0.
--
-- WHY THE CUT IS ROLLED AT THE TRADE. There is one steak item (3959), not five, and
-- bg-wiki says the cut "will be chosen randomly" -- so the cut is a property of the
-- handover rather than of the item, and a rejected steak is consumed exactly as
-- bg-wiki describes ("it is possible to receive multiple undesired cuts"). The 1-in-5
-- chance is the five-way ${choice} in 7543, not a rate invented here.
--
-- ITEM: Delectable Orobon Steak is id 3959 (`item_basic` name
-- `delectable_orobon_steak`), which had no enum name and was added as
-- DELECTABLE_OROBON_STEAK after checking the id was unused.
-- KEY ITEMS: Paresis resilience is the existing PARESIS_RESILIENCE (2208); the badge
-- 7537 asks for is PIONEERS_BADGE (2157). Note 2157 is ALSO item id 2157 (Imp Horn) --
-- 7537's placeholder is ${keyitem-article}, so it is the key item. Checked by id.
--
-- ON "A FISHING ROD": bg-wiki lists it under |Quest Reqs=, but it is equipment needed
-- to catch the orobon, not a quest flag -- there is no such gate in the event block
-- either, so nothing is gated on it here.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.OROBON_APPETIT)

local liverCut = 0 -- 7543's ${choice: 0} order: liver, cheeks, stomach, back, tail
local cutCount = 5

quest.reward =
{
    keyItem  = xi.ki.PARESIS_RESILIENCE,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- Not a registered pioneer: 7537 turns you away.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                not player:hasKeyItem(xi.ki.PIONEERS_BADGE)
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Nestroh'] = quest:event(2570):replaceDefault(),
        },
    },

    -- bg-wiki lists no |Previous=; the badge is the only gate.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Nestroh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2571, { [0] = xi.item.DELECTABLE_OROBON_STEAK })
                end,
            },

            onEventFinish =
            {
                [2571] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: keep bringing steaks until one of them is the liver.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Nestroh'] =
            {
                onTrade = function(player, npc, trade)
                    if not npcUtil.tradeHasExactly(trade, xi.item.DELECTABLE_OROBON_STEAK) then
                        return
                    end

                    local cut = math.random(0, cutCount - 1)

                    if cut == liverCut then
                        return quest:progressEvent(2574, { [0] = cut })
                    end

                    return quest:progressEvent(2573, { [0] = cut })
                end,

                onTrigger = function(player, npc)
                    return quest:event(2572, { [0] = xi.item.DELECTABLE_OROBON_STEAK })
                end,
            },

            onEventFinish =
            {
                -- A wrong cut: he eats it and sends you back out (7550).
                [2573] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,

                [2574] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7561, already planning the next catch.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Nestroh'] = quest:event(2575):replaceDefault(),
        },
    },
}

return quest
