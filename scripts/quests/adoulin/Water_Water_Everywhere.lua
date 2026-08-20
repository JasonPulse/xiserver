-----------------------------------
-- Water, Water, Everywhere
-----------------------------------
-- Log ID: 9, Quest ID: 32
-- Jhen_Durheka : Marjami Ravine, Frontier Bivouac #1, entity 17867206
-- qm (K-5)     : Marjami Ravine, entity 17867207
-- qm (H-10)    : Marjami Ravine, entity 17867208
-- qm (H-9)     : Dho Gates,      entity 17891724
-- !addquest 9 32
-----------------------------------
-- Retail (bg-wiki "Water, Water, Everywhere").
-- |Start=Jhen Durheka, Marjami Ravine  |Fame=Seekers of Adoulin  |FLevel=4+
-- |Quest Reqs="Climbing"  |Reward=2000 Experience Points
--   1. Speak to Jhen Durheka at Frontier Bivouac #1 to obtain the Ravine water
--      testing kit.
--   2. "Visit three specific places and obtain water samples from them by clicking
--      on the ???. They can be found in any order."
--      - (K-5) next to the ergon locus
--      - (H-10) on the east side of the river
--      - Dho Gates (H-9) on the west side of the stream
--   3. Return to Jhen Durheka for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Jhen Durheka is 17867206 -> zone 266 idx 454 (0x0110A1C6). The dumped dialog file
-- labelled zone N holds zone N-1's text for the Adoulin FIELD zones, so Marjami's
-- text is in the file labelled 267 and Dho Gates' in 273; the offset is pinned by
-- this repo's own known-correct id (Marjami_Ravine/IDs.lua WAYPOINT_ATTUNED = 7705
-- resolves in dump 267). Read against 267:
--   45 -> 7830       his warning before the quest: "Numerous Velkk clans rrreside in
--         this area. I don't care how battleworn you are--don't let your guard down."
--   46 -> 7831-7838  THE OFFER. 7832 is the accept prompt: "Up for some Velkk
--         skinning? ${selection-lines} Bloody pulp, here I come! / Violence is never
--         the answer." -- the affirmative is the FIRST line, so OPTION 0 ACCEPTS,
--         and 7833 is the decline. 7834 "I'm Jhen Durheka, in charge of surveying
--         water quality here", and 7836 carries both the key item and the task: "Take
--         this ${keyitem-singular: 0[2]} and procure samples at both the source and
--         the mouth of the river, as well as at the Dho G[ates]." 7837 "The water,
--         you see, flows down from the ravine here into the gates."
--   47 -> 7839       the reminder: "I need you to take samples upstream, downstream,
--         and at the Dho Gates."
--   48 -> 7840-7842  THE TURN-IN. 7841 "Unlike Yorcia and Hennetiel, the water here
--         is pure. The pollution in those areas must be coming from Cirdas Caverns."
--   The sample message is "You scooped up some water with your
--         ${keyitem-singular: 0[2]}." -- 7843 in Marjami's table and 7725 in Dho
--         Gates'. The three ??? own no csids, so this is a plain message rather than
--         an event, the same shape the Shellfish points use.
--
-- WHICH THREE ???, AND WHY THESE ARE NOT GUESSES. Marjami has eight qm entities and
-- Dho Gates four, so each point was pinned independently:
--   * (K-5) "next to the ergon locus" -> qm 17867207 (226.0, 283.0) sits 15 units
--     from Ergon_Locus 17867153 (240.0, 285.0). The next nearest qm to any locus is
--     70 units away, so this one is unambiguous.
--   * Dho Gates (H-9) -> qm 17891724 (-224.3, 146.3). Dho Gates calibrates off two
--     entities whose grid refs bg-wiki states outright -- Rocky_Outcrop 17891727
--     (-290.0, 219.2) at (G-8) from Velkkovert Operations, and Inlet_of_Whispers
--     17891738 (-333.3, -100.4) at (F-12) from Saved by the Bell -- giving 43.3 units
--     per column and 79.9 per row with z decreasing as the row rises. That puts (H-9)
--     at about (-246.7, 139.3), which is 23 units from 17891724; the only other
--     candidate, 17891694, is roughly 940 units away.
--   * (H-10) -> qm 17867208. This one is structural rather than positional: exactly
--     TWO Marjami qms own no csid at all (17867207 and 17867208) and bg-wiki wants
--     exactly TWO Marjami samples, so once 17867207 is fixed as the K-5 point,
--     17867208 is the only remaining candidate of that class. Its coordinates
--     (-10.0, -78.0) land in I-10 rather than H-10 under the Marjami calibration
--     (Veldeth (L-7) at (350.6, 137.5) with the K-5 point giving 124.6/column and
--     72.75/row), so it sits about one column east of bg-wiki's hand-written ref --
--     which is within the slop of a wiki grid reference, and its row is exact.
--
-- KEY ITEM: Ravine water testing kit is the existing RAVINE_WATER_TESTING_KIT (2382).
-- Note 2382 is ALSO item id 2382 (a bottle of green chocobo dye); 7836's placeholder
-- is ${keyitem-singular}, so it is the key item. Checked by id in both enums.
--
-- ON "CLIMBING": bg-wiki lists it under |Quest Reqs= and notes two of the three ???
-- need it, but it is an Adoulin survival-skill unlock used to reach the spots, not a
-- quest flag this script can test -- and there is no such gate in the event block
-- either. Movement ability is left to the zone geometry, as with Unsullied Lands.
--
-- PROGRESS is a three-bit mask in the quest var 'Samples', one bit per site, so the
-- three can be taken in any order -- which is what bg-wiki's "They can be found in
-- any order" requires.
-----------------------------------
local marjamiID  = zones[xi.zone.MARJAMI_RAVINE]
local dhoGatesID = zones[xi.zone.DHO_GATES]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.WATER_WATER_EVERYWHERE)

-- sample ??? entity -> bit
local sampleBit =
{
    [17867207] = 0, -- Marjami (K-5), beside the ergon locus
    [17867208] = 1, -- Marjami (H-10), east side of the river
    [17891724] = 2, -- Dho Gates (H-9), west side of the stream
}

local allSamples = 0x07 -- three bits

quest.reward =
{
    exp      = 2000,
    fameArea = xi.fameArea.ADOULIN,
}

-- Both zones carry the same line under their own id.
local scoopWater = function(player, npc, textId)
    local bit1 = sampleBit[npc:getID()]
    if bit1 == nil then
        return
    end

    local mask = quest:getVar(player, 'Samples')
    if bit.band(mask, bit.lshift(1, bit1)) == 0 then
        quest:setVar(player, 'Samples', bit.bor(mask, bit.lshift(1, bit1)))
    end

    player:messageSpecial(textId, xi.ki.RAVINE_WATER_TESTING_KIT)
end

quest.sections =
{
    -- bg-wiki lists no |Previous=; |FLevel=4+ is the only stated gate.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 4
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Jhen_Durheka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(46, { [0] = xi.ki.RAVINE_WATER_TESTING_KIT })
                end,
            },

            onEventFinish =
            {
                [46] = function(player, csid, option, npc)
                    -- 7832: 0 "Bloody pulp, here I come!", 1 "Violence is never the
                    -- answer."
                    if option ~= 0 then
                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Samples', 0)

                    -- 7836: he hands over the kit with the task.
                    npcUtil.giveKeyItem(player, xi.ki.RAVINE_WATER_TESTING_KIT)
                end,
            },
        },
    },

    -- Accepted: three samples, any order, then back to the bivouac.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    scoopWater(player, npc, marjamiID.text.SCOOPED_UP_WATER)
                end,
            },

            ['Jhen_Durheka'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Samples') == allSamples then
                        return quest:progressEvent(48, { [0] = xi.ki.RAVINE_WATER_TESTING_KIT })
                    end

                    return quest:event(47, { [0] = xi.ki.RAVINE_WATER_TESTING_KIT })
                end,
            },

            onEventFinish =
            {
                [48] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.RAVINE_WATER_TESTING_KIT)

                    if quest:complete(player) then
                        quest:setVar(player, 'Samples', 0)
                    end
                end,
            },
        },

        [xi.zone.DHO_GATES] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    scoopWater(player, npc, dhoGatesID.text.SCOOPED_UP_WATER)
                end,
            },
        },
    },

    -- Completed: 7830, back to warning passers-by about the Velkk.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MARJAMI_RAVINE] =
        {
            ['Jhen_Durheka'] = quest:event(45):replaceDefault(),
        },
    },
}

return quest
