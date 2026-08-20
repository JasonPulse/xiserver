-----------------------------------
-- Unsullied Lands
-----------------------------------
-- Log ID: 9, Quest ID: 12
-- Inmot-Pinmot : Foret de Hennetiel (J-10), entity 17850922
-- Ergon_Locus  : Foret de Hennetiel (J-11), entity 17850951
-- !addquest 9 12
-----------------------------------
-- Retail (bg-wiki "Unsullied Lands").
-- |Start=Inmot-Pinmot, Foret de Hennetiel - (J-10)  |Fame=Adoulin  |FLevel=1
-- |Quest Reqs="Watercrafting"  |Reward=2000 Experience Points
--   1. Talk to Inmot-Pinmot at Bivouac #2 to accept the quest.
--   2. "Head west towards the beach (with a tree reive), but instead of crossing
--      the tree, head south along the coast until you reach the secret beach at
--      (J-11)."
--   3. Examine the Ergon Locus to obtain a Fistful of pristine sand.
--   4. Return to Inmot-Pinmot for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Inmot-Pinmot is 17850922 -> zone 262 idx 554 (0x0110622A). `xi-dat events 262`
-- gives him 2520, 2521, 2522, 2524, 2525. The dumped dialog file labelled zone N
-- holds zone N-1's text for the Adoulin zones, so Foret's text is in the file
-- labelled 263; the offset is pinned by this repo's own known-correct id
-- (Foret_de_Hennetiel/IDs.lua WAYPOINT_ATTUNED = 7688 resolves in dump 263).
-- Read against 263:
--   2520 -> 7509-7512  THE OFFER. 7509 "did you come across any unsully-wullied
--          land?", 7510 "These areas are keptaru clean by mystical forces known as
--          'ergon loci'", and 7511 "If you find one, can you collectaru a bunch of
--          sand from the area?" No ${selection-lines}, so speaking to him starts it.
--   2521 -> 7512       the reminder: you will recognize a locus at first sight.
--   2522 -> 7513-7516  THE TURN-IN. "You found it! You really found it! ... It's
--          both pure and clean. My experimentations can now continue!"
--   2524 -> 7517/7518  THE BEACH. 7517 "${choice: 1}[Defiled/Pure white] sand
--          stretches out before you." and 7518 "An aura of tranquility embraces
--          the land and soothes your heart."
--   2525 -> 7516       his post-completion line.
--
-- WHICH LOCUS, AND WHY IT IS NOT A GUESS. Foret has four Ergon_Locus entities
-- (17850951-54) and all four own only the generic geomagnetic-fount csids
-- (3007-3010), which are the waypoint attunement system, not this quest. The one
-- bg-wiki wants is identified by grid arithmetic off three NPCs whose grid refs
-- bg-wiki states outright:
--     Fritha        (411.3,  269.4) = J-7
--     River_Mouth   (462.0,  -58.0) = J-9
--     Inmot-Pinmot  (502.0, -302.3) = J-10
-- so in this zone the J column is x ~410-530 and z DECREASES about 200 per row as
-- the row number rises. Row 11 therefore sits near z -500, and of the four loci
-- only 17850951 at (467.2, -377.9) is in the J column south of Inmot-Pinmot; the
-- others are at (529.9, 157.6) -- around row 8 -- and far west at x -201 and -431.
-- That also matches bg-wiki's route: south along the coast from Bivouac #2.
--
-- 7517's ${choice: 1} is the reason only one locus yields sand -- the same line
-- renders "Defiled" at the polluted loci and "Pure white" at this one. The other
-- three are left to the waypoint system rather than being given a quest handler.
--
-- KEY ITEM: Fistful of pristine sand is the existing FISTFUL_OF_PRISTINE_SAND
-- (2186).
--
-- ON "WATERCRAFTING": bg-wiki lists it under |Quest Reqs=, but it is one of the
-- Adoulin survival-skill unlocks used to reach the beach, not a quest flag this
-- script can test -- there is no such gate in the event block either. Movement
-- ability is left to the player, exactly as the zone geometry enforces it.
-----------------------------------
local foretID = zones[xi.zone.FORET_DE_HENNETIEL]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.UNSULLIED_LANDS)

local pristineLocus = 17850951 -- (467.2, -377.9), the J-11 secret beach

quest.reward =
{
    exp      = 2000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous=, and |FLevel=1 is the base fame level every
    -- character already has.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Inmot-Pinmot'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2520)
                end,
            },

            onEventFinish =
            {
                [2520] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: find the pristine locus, take sand, report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Ergon_Locus'] =
            {
                onTrigger = function(player, npc)
                    -- Only the J-11 locus is pure; at the others 7517 renders
                    -- "Defiled" and nothing is collected. Returning nothing there
                    -- leaves the waypoint attunement handler to run as normal.
                    if npc:getID() ~= pristineLocus then
                        return
                    end

                    if player:hasKeyItem(xi.ki.FISTFUL_OF_PRISTINE_SAND) then
                        return
                    end

                    player:messageSpecial(foretID.text.SAND_STRETCHES_OUT, 0, 1)
                    player:messageSpecial(foretID.text.AURA_OF_TRANQUILITY)
                    npcUtil.giveKeyItem(player, xi.ki.FISTFUL_OF_PRISTINE_SAND)
                end,
            },

            ['Inmot-Pinmot'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FISTFUL_OF_PRISTINE_SAND) then
                        return quest:progressEvent(2522)
                    end

                    return quest:event(2521)
                end,
            },

            onEventFinish =
            {
                [2522] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.FISTFUL_OF_PRISTINE_SAND)
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7516, back to cleansing the whole river.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.FORET_DE_HENNETIEL] =
        {
            ['Inmot-Pinmot'] = quest:event(2525):replaceDefault(),
        },
    },
}

return quest
