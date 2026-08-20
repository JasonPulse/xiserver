-----------------------------------
-- Destiny Odyssey
-----------------------------------
-- Log ID: 8, Quest ID: 50
-- Goraow : Abyssea - Misareaux (H-4), entity 17662729
-- !addquest 8 50
-----------------------------------
-- Retail (bg-wiki "Destiny Odyssey").
-- |Start=Goraow (A), Abyssea - Misareaux  |Previous=I Dream of Flowers
-- |Item Reqs=Sanguine Spike  |Reward=1,500 Cruor, Sapphire abyssite of sojourn
--   1. Zone after completing the previous quest.
--   2. Speak to Goraow (A) at (H-4). He will request a Sanguine Spike.
--      Sanguine Spikes drop from the peiste NM Gukumatz, northeast of Conflux #7.
--   3. Trade the Sanguine Spike to Goraow (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. As with I_Dream_of_Flowers.lua, Goraow's own
-- programs are 1-byte stubs and the bytecode lives on holder 17662724
-- (0x010D8304) -- csidmsg.py and csidscan.py both come back empty against the
-- visible NPC, so the holder is what has to be scanned:
--   164 -> 8211-8224  THE OFFER. 8213/8214 name the beast ("a fearsome peiste
--          known far and wide as Gukumatz"), 8217 hands you the destiny, and
--          8218 is the accept prompt: "Embrace your destiny? ${selection-lines}
--          Wholeheartedly! / Cast it aside." -- the affirmative is the FIRST
--          line, so OPTION 0 ACCEPTS, and 8219/8220 are the decline. 8222 then
--          states the actual fetch: "I need you to bring back a trophy--some
--          part of Gukumatz's carcass." The trophy is param 1.
--   165 -> 8222-8224  the reminder, the trophy request without the preamble.
--   166 -> 8225-8227  THE TURN-IN. 8225 "<Gasp>! If it isn't the
--          ${item-singular: 1[2]} of Gukumatz! And nice and bloody, too", 8227
--          "By way of thanks, I want you to have this."
--   167 -> 8226       the short version of his thanks.
--
-- MUST ZONE: bg-wiki's first walkthrough line is "Zone after completing the
-- previous quest", so the gate is I Dream of Flowers completed AND a zone since,
-- not merely the predecessor's completion.
--
-- ITEM: bg-wiki calls it "Sanguine Spike"; this repo's enum spells the same id
-- (2961) SANQUINE_SPIKE -- a misspelling that already exists in scripts/enum/
-- item.lua. Checked by id rather than by name; the enum name is used as-is
-- rather than renamed, since renaming it would touch unrelated callers.
-----------------------------------
local misareauxID = zones[xi.zone.ABYSSEA_MISAREAUX]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.DESTINY_ODYSSEY)

local cruorReward = 1500

quest.reward =
{
    keyItem = xi.ki.SAPPHIRE_ABYSSITE_OF_SOJOURN,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.I_DREAM_OF_FLOWERS) and
                quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(164, { [1] = xi.item.SANQUINE_SPIKE })
                end,
            },

            onEventFinish =
            {
                [164] = function(player, csid, option, npc)
                    -- 8218: 0 "Wholeheartedly!", 1 "Cast it aside."
                    if option == 0 then
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

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.SANQUINE_SPIKE) then
                        return quest:progressEvent(166, { [1] = xi.item.SANQUINE_SPIKE })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(165, { [1] = xi.item.SANQUINE_SPIKE })
                end,
            },

            onEventFinish =
            {
                [166] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(misareauxID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_MISAREAUX] =
        {
            ['Goraow'] = quest:event(167, { [1] = xi.item.SANQUINE_SPIKE }):replaceDefault(),
        },
    },
}

return quest
