-----------------------------------
-- Beast from the East
-----------------------------------
-- Log ID: 7, Quest ID: 30
-- Nichais        : Southern San d'Oria [S] (L-7)
-- Timeworn Altar : Grauberg [S] (F-11)
-----------------------------------
-- Retail (bg-wiki "Beast from the East"), not repeatable:
--   1. Speak to Nichais at Southern San d'Oria [S] (L-7) for a cutscene, and
--      choose "Immensely, yes". Choosing "Not in the least, no" just means
--      leaving and starting the scene again.
--   2. Travel to Grauberg [S] and check the Timeworn Altar at (F-11) for a long
--      cutscene.
--   3. Return to Nichais for a cutscene.
--   4. Obtain a Shell Bug from a Brass Quadav in the PRESENT era and trade it to
--      Nichais for the fourth scene.
--   5. Return to the altar for the final cutscene and the reward: two random
--      jewels drawn from a list of fifteen.
-- Title: Wyrmsworn Protector. No fame value is listed, so none is granted.
--
-- CSIDs decoded, not guessed, and resolved to actual message ids rather than
-- inferred from position. Nichais is entity 17105607 (npc_list:8393);
-- (17105607-16777216) = 328391, 328391//4096 = 80 rem 711 -> Southern San d'Oria
-- [S], 0x010502C7. `xi-dat events 80` shows the entity owning 72, 74, 75, 76, 77,
-- 79, 80 and 83 outright -- csids 71, 73 and 78 appear in its listing but their
-- real programs live elsewhere (see below).
--
-- Resolved with xidat/csidmsg.py's find_msg against the zone 80 dialog table:
--   83 -> 13563-13565  the pre-quest approach. 13563 "I wonder if perhaps... No,
--         it couldn't be...", 13564 "Wh--!? My apologies... You gave me a bit of
--         a start", 13565 "I beg your indulgence. My mind wanders and is ill at
--         ease."
--   72 -> 13566-13589  THE OFFER, and what pins it is 13567: "Does this talk
--         interest you? ${selection-lines} Immensely, yes. Not in the least, no."
--         -- word for word the choice bg-wiki names, with "Immensely, yes" FIRST,
--         so option 0 accepts. The scene runs through the Eastdrake legend
--         (13576-13580, "The Eastdrake thus became the Mountain's Eye") and ends
--         13588 "would you mind investigating the premises for me?" / 13589
--         "I would forever be in your debt".
--   74 -> 13606-13615  the return after the altar. 13609 is the riddle, "An
--         ageless armor, impenetrable, and yet of no metal wrought. To lay at
--         rest only the comfort of anvil-hard beds are sought.", and 13614 asks
--         you to bring anything that fits the description.
--   75 -> 13616-13617  a WRONG item: "I'm not sure I see the relevance."
--   76 -> 13618-13620  a WRONG item: "you may be on to something with this...
--         Alas, I fear this may be a bit too large."
--   77 -> 13621-13622  a WRONG item: "An authentic ${item-singular: 0[2]}! ...an
--         ancient tome such as this would never make for a practical daily
--         offering."
--   78 -> 13623-13632  THE SHELL BUG, i.e. the correct trade. 13625 "'An ageless
--         armor, impenetrable, and yet of no metal wrought.' ...The shell bug
--         certainly is armored.", 13627 "the shell bug is a parasite which
--         thrives within the shells of Quadav!", 13628 "the 'anvil-hard beds' is
--         a reference to the Quadav shells". Its program does NOT sit on Nichais
--         -- it is on the invisible holder 'blank' 0x010502C5 (17105605,
--         npc_list:8391), two indices before him, with 1-byte stubs elsewhere.
--   79 -> 13632, 80 -> 13633-13635  the closing scenes.
--
-- Timeworn Altar is entity 17142597 (npc_list:10070); (17142597-16777216) =
-- 365381, 365381//4096 = 89 rem 837 -> Grauberg [S], 0x01059345. It owns exactly
-- TWO csids, 17 and 18, matching the two altar visits, and again the real
-- programs are on the invisible holder 'blank' 0x01059343 (17142595,
-- npc_list:10068) with 1-byte stubs on the altar:
--   17 ->  4023 bytes, the first long cutscene
--   18 -> 16194 bytes, the final cutscene and the award -- by far the largest
--         program in the pair, which is consistent with it carrying the reward.
--
-- The previous stub fired csid 1240, part of the fabricated arithmetic sequence
-- keyed to quest id (1000, 1010, 1040 ... 1580); `xi-dat csid 80 1240` reports it
-- not found in zone 80, so triggering Nichais did nothing at all. The stub also
-- claimed `fameArea = SANDORIA` with `fame = 30`; bg-wiki's Fame field is
-- "Wings of the Goddess" and no numeric value is given, so no fame is granted.
-- The stub's header also carried a mangled location, "SOUTHERN [S]AN DORIA [S]",
-- from a bad string replace in whatever generated it.
--
-- Crystal War zones are NOT dialog-offset; zone 80's own table reads correctly.
--
-- STILL SIMPLIFIED, and flagged rather than faked: csids 75, 76 and 77 are three
-- DISTINCT wrong-item responses, and which specific item each one answers is not
-- decoded -- 77 clearly answers a rare tome ("An authentic ${item-singular}"),
-- but 75 and 76 are generic. Only the correct Shell Bug path and a single
-- generic wrong-item reply (75) are wired; 76 and 77 are documented above so the
-- ids are not lost.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BEAST_FROM_THE_EAST)

quest.reward =
{
    title = xi.title.WYRMSWORN_PROTECTOR,
}

-- bg-wiki: "2 of the following". All fifteen verified present in
-- scripts/enum/item.lua.
local jewels =
{
    xi.item.BLACK_PEARL,
    xi.item.CHRYSOBERYL,
    xi.item.JADEITE,
    xi.item.AMETRINE,
    xi.item.ZIRCON,
    xi.item.GOSHENITE,
    xi.item.SPHENE,
    xi.item.FLUORITE,
    xi.item.PERIDOT,
    xi.item.GARNET,
    xi.item.TURQUOISE,
    xi.item.PAINITE,
    xi.item.SUNSTONE,
    xi.item.MOONSTONE,
    xi.item.PEARL,
}

-- Two draws, and they may repeat -- bg-wiki says only "2 of the following".
local function drawJewels()
    return { jewels[math.random(1, #jewels)], jewels[math.random(1, #jewels)] }
end

quest.sections =
{
    -- Offer. 13567 "Does this talk interest you? / Immensely, yes. / Not in the
    -- least, no."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Nichais'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(72)
                end,
            },

            onEventFinish =
            {
                [72] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted, first altar visit outstanding.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Nichais'] = quest:event(83),
        },

        [xi.zone.GRAUBERG_S] =
        {
            ['Timeworn_Altar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(17)
                end,
            },

            onEventFinish =
            {
                [17] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- Altar seen: report back to Nichais, who then sets the riddle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Nichais'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(74)
                end,
            },

            onEventFinish =
            {
                [74] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },
    },

    -- The riddle is set: trade the Shell Bug.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 2
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Nichais'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(74)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.SHELL_BUG) then
                        return quest:progressEvent(78)
                    end

                    -- 13617 "I'm not sure I see the relevance."
                    return quest:progressEvent(75)
                end,
            },

            onEventFinish =
            {
                [78] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 3)
                end,
            },
        },
    },

    -- Back to the altar for the final cutscene and the two jewels.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 3
        end,

        [xi.zone.GRAUBERG_S] =
        {
            ['Timeworn_Altar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(18)
                end,
            },

            onEventFinish =
            {
                [18] = function(player, csid, option, npc)
                    -- Granted directly rather than through quest.reward.item:
                    -- quest is a single shared object, so assigning the roll to
                    -- it would leak one player's jewels to the next completer.
                    if npcUtil.giveItem(player, drawJewels()) then
                        quest:complete(player)
                    end
                end,
            },
        },
    },

    -- 13633-13635, the closing lines.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Nichais'] = quest:event(80),
        },
    },
}

return quest
