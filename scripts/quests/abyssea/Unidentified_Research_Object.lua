-----------------------------------
-- Unidentified Research Object
-----------------------------------
-- Log ID: 8, Quest ID: 51
-- Yurim : Abyssea - Misareaux (K-7), entity 17662733
-- !addquest 8 51
-----------------------------------
-- Retail (bg-wiki "Unidentified Research Object").
-- |Start=Yurim (A), Abyssea - Misareaux  |Repeatable=Yes  |Fame=amis  |FLevel=1
-- |Item Reqs=Murex Spicule
-- |Reward=800 Cruor, 400 Cruor for repeat completions
--   1. Speak to Yurim (A) at the base camp (K-7) to begin the quest.
--   2. "She says she wants you to get something for her research, but forgets
--      what it is."
--   3. "Optional: Trade her an Apple Pie and she will remember she needs a Murex
--      Spicule. If you trade her an Apple Pie +1, the dialogue flavor text
--      changes."
--   4. Escarp Murex spawn just to the west at (J-7).
--   5. Trade her a Murex Spicule to complete the quest.
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED, AND THE HOLDER MATTERED HERE. Yurim is 17662733
-- (zone 216 idx 781); like the rest of the visible Misareaux NPCs her programs are
-- stubs, and the real bytecode sits on holder 17662724 (0x010D8304). csidmsg.py and
-- csidscan.py both return nothing pointed at Yurim; scanning the HOLDER resolves
-- them, and `xi-dat events 216` is what attributes 229-235 to her:
--   229 -> 8230-8236  THE OFFER. 8232 "There is a certain object that I require",
--          8233 "Its name, however, eludes me", and 8235/8236 "I feel...faint...
--          I fear lack of nourishment is having an adverse effect on my mental
--          functions. A sugar-rich diet is needed" -- the pie hint. No
--          ${selection-lines}, so speaking to her starts it.
--   230 -> 8237-8239  the reminder: still cannot recall the name.
--   231 -> 8240-8246  THE PIE. 8240 "<Gasp>! ${lettercase: 1}${article}
--          ${item-article: 2[2]}...for me?" and then 8245 "${lettercase: 1}
--          ${item-singular: 1[2]}! Only with ${article} ${item-article: 1[2]} will
--          I be able to complete my research!" -- the pie is param 2 and the
--          spicule is param 1, which is how one event names both items.
--   232 -> 8247-8251  the same recollection with different flavour, closing on
--          8250/8251 praising your "intuition and resourcefulness" -- this is the
--          Apple Pie +1 variant bg-wiki mentions.
--   233 -> 8252-8256  THE TURN-IN. "Ah! The...thing...that I need! You've really
--          brought it!" / 8254 "Please accept this as a small token."
--   234 -> 8255/8256  her post-completion lines.
--   235 -> 8257/8258  the repeat offer: "I'm once more depleted of that...thing."
--
-- THE ITEM IDS ARE THE EVENT'S OWN. Loading the holder with csidmsg.load() shows
-- its data[] carries 2640 (Murex Spicule), 4413 (Apple Pie) and 4320 (Apple
-- Pie +1) alongside the message ids, so the events read the items out of the block
-- rather than from startEvent and are fired bare.
--
-- ITEMS: Murex Spicule is id 2640 and Apple Pie +1 is id 4320; neither had an enum
-- name and both were added after checking the ids were unused. Apple Pie already
-- had APPLE_PIE (4413).
--
-- THE PIE IS GENUINELY OPTIONAL, per bg-wiki -- it only changes which recollection
-- event plays. The spicule trade completes the quest either way, so the pie sets a
-- flavour var rather than gating progress.
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNIDENTIFIED_RESEARCH_OBJECT)

local firstCruor  = 800
local repeatCruor = 400

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_MISAREAUX,
}

quest.sections =
{
    -- COMPLETED is accepted because |Repeatable=Yes; 235 is her re-offer.
    {
        check = function(player, status, vars)
            -- bg-wiki: "Zoning is required in order to repeat this quest."
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                not quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yurim'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNIDENTIFIED_RESEARCH_OBJECT) then
                        return quest:progressEvent(235)
                    end

                    return quest:progressEvent(229)
                end,
            },

            onEventFinish =
            {
                [229] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [235] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNIDENTIFIED_RESEARCH_OBJECT)
                end,
            },
        },
    },

    -- Accepted: the spicule completes it; the pie is a detour for flavour.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yurim'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.MUREX_SPICULE) then
                        return quest:progressEvent(233)
                    elseif npcUtil.tradeHasExactly(trade, xi.item.APPLE_PIE_1) then
                        return quest:progressEvent(232)
                    elseif npcUtil.tradeHasExactly(trade, xi.item.APPLE_PIE) then
                        return quest:progressEvent(231)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(230)
                end,
            },

            onEventFinish =
            {
                -- Both pie events consume the pie and leave the quest active.
                [231] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,

                [232] = function(player, csid, option, npc)
                    player:confirmTrade()
                end,

                [233] = function(player, csid, option, npc)
                    local first = not player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNIDENTIFIED_RESEARCH_OBJECT)

                    player:confirmTrade()

                    if quest:complete(player) then
                        local cruor = first and firstCruor or repeatCruor

                        player:addCurrency('cruor', cruor)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
                        xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.UNIDENTIFIED_RESEARCH_OBJECT)
                    end
                end,
            },
        },
    },

    -- Completed: 8255/8256, the world as a scientist's playground.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Yurim'] = quest:event(234):replaceDefault(),
        },
    },
}

return quest
