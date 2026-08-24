-----------------------------------
-- A Sterling Specimen
-----------------------------------
-- Log ID: 8, Quest ID: 25
-- Ohbiru-Dohbiru       : Abyssea - Tahrongi (H-7), entity 16962103
-- Kenapa-Keppa         : Abyssea - Tahrongi (I-7), entity 16962104
-- Lycopodium_Rootprint : Abyssea - Tahrongi (H-7), entity 16962119
-- Rubicund_Adenium     : Abyssea - Tahrongi, mobs 16961537 / 16961538 / 16961539
-- !addquest 8 25
-----------------------------------
-- Retail (bg-wiki "A Sterling Specimen").
-- |Start=Ohbiru-Dohbiru (A) (H-7), Abyssea - Tahrongi  |Fame=atah |FLevel=3
-- |Reward=Dance Shoes with augments  |Repeatable=Yes
--   1. "Speak to Ohbiru-Dohbiru (A) at (H-7) and tell him you have found a pink fiend
--      in the area."
--   2. "Next talk to Kenapa-Keppa (A) in the northeast corner of (I-7) to receive KI
--      Bucket of compound compost."
--   3. "Click the Lycopodium Rootprint targetable location which is west of the
--      mountain at (H-7). This will spawn Rubicund Adenium, a Mandragora."
--   4. "Bring it to Kenapa-Keppa (A) to capture it, making sure not to let it despawn
--      along the way (keep it within 20')."
--   5. "Lastly, speak with Kenapa-Keppa (A) after the full Warp II animation to
--      complete the quest."
--   "Zoning is required to repeat this quest."
--   "This quest may only be completed once per Vana'diel day."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Ohbiru-Dohbiru 344 -> 7955/7956  his idle lines about the Windurst ministers.
--   Ohbiru-Dohbiru 345 -> 7957-7962  THE OFFER. 7958 is the two-way menu ("I have
--          not." / "I have!"), and note the accepting line is the SECOND one, which
--          is why the option test below is inverted relative to most of these. 7959
--          is the "Well, drat!" brush-off for the first.
--   Ohbiru-Dohbiru 346 -> 7964  the reminder, "speak to Kenapa-Keppa outside".
--   Ohbiru-Dohbiru 347 -> 7974-7978  his post-capture debrief.
--   Ohbiru-Dohbiru 348 -> 7976-7978  the same research lecture on its own.
--   Ohbiru-Dohbiru 349 -> 7980/7981  the repeat offer, "that splendid specimen you
--          caught for us? Well, while I was writing up my lat[est notes]..."
--   Kenapa-Keppa 350 -> 7965  his idle, "Not...safe...here... You...should...go..."
--   Kenapa-Keppa 351 -> 7966-7970  he hands the compost over: "Take...this..." /
--          "South...west...a...thicket... A...cactus... You'll...see..." /
--          "Use...this... Something...will...come... Maybe..."
--   Kenapa-Keppa 352 -> 7967-7970  the same directions as a reminder.
--   Kenapa-Keppa 353 -> 7972/7973  THE CAPTURE. "Truly...remarkable... I...haven't...
--          been...this...excited...in...years..." and "This...${keyitem-singular:
--          0[2]}...worthless...now... I'll...throw...it...out...", which is the
--          compost being consumed.
--   Kenapa-Keppa 354 -> 7972  the same excitement on its own.
--   Kenapa-Keppa 355 -> 7979  "We're...sorry... So...so...sorry..."
--
-- THE ROOTPRINT HAS NO EVENT PROGRAM. csidmsg.load returns nothing for 16962119, so
-- using the compost there is a plain interaction; the visible result is the
-- Rubicund Adenium spawning, which is the pop system's job and not a cutscene.
--
-- "KEEP IT WITHIN 20'" is the whole difficulty of the quest, and it is checked at
-- Kenapa-Keppa rather than tracked continuously: the capture only fires if a live
-- Rubicund Adenium is actually standing next to him. Walking off and losing it simply
-- means there is nothing there to capture.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_STERLING_SPECIMEN)

local rootprint = 16962119

local adeniumMobs = { 16961537, 16961538, 16961539 }

-- bg-wiki's "keep it within 20'".
local captureRange = 20

-- 7958's SECOND line, "I have!", is the accepting one.
local optionSeenIt = 1

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

--- True when a live Rubicund Adenium is close enough to Kenapa-Keppa to be caught.
local specimenIsHere = function(npc)
    for _, mobId in ipairs(adeniumMobs) do
        local mob = GetMobByID(mobId)

        if
            mob ~= nil and
            mob:isSpawned() and
            mob:checkDistance(npc) <= captureRange
        then
            return true
        end
    end

    return false
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_TAHRONGI) >= 3
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Ohbiru-Dohbiru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(345)
                end,
            },

            onEventFinish =
            {
                [345] = function(player, csid, option, npc)
                    if option ~= optionSeenIt then
                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Prog', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kenapa-Keppa'] =
            {
                onTrigger = function(player, npc)
                    if specimenIsHere(npc) then
                        return quest:progressEvent(353, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    elseif player:hasKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST) then
                        return quest:event(352)
                    elseif quest:getVar(player, 'Prog') >= 1 then
                        return quest:event(354)
                    end

                    return quest:progressEvent(351, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                end,
            },

            ['Lycopodium_Rootprint'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= rootprint or
                        not player:hasKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    then
                        return
                    end

                    -- The pop itself belongs to the zone's spawn handling; all this
                    -- records is that the compost has been put to use.
                    quest:setVar(player, 'Prog', 1)

                    return true
                end,
            },

            ['Ohbiru-Dohbiru'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') >= 2 then
                        return quest:progressEvent(347)
                    end

                    return quest:event(346)
                end,
            },

            onEventFinish =
            {
                [351] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                end,

                [353] = function(player, csid, option, npc)
                    -- 7973: the compost is spent in the capture.
                    player:delKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    quest:setVar(player, 'Prog', 2)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                        npcUtil.giveItem(player, xi.item.DANCE_SHOES)
                    end
                end,
            },
        },
    },

    -- Repeatable, but bg-wiki adds "This quest may only be completed ONCE per
    -- Vana'diel day" on top of the usual zoning requirement.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Kenapa-Keppa'] =
            {
                onTrigger = function(player, npc)
                    if specimenIsHere(npc) then
                        return quest:progressEvent(353, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    elseif player:hasKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST) then
                        return quest:event(352)
                    elseif quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(351, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    end

                    return quest:event(350)
                end,
            },

            ['Lycopodium_Rootprint'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= rootprint or
                        not player:hasKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    then
                        return
                    end

                    quest:setVar(player, 'Prog', 2)

                    return true
                end,
            },

            ['Ohbiru-Dohbiru'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Day') == VanadielUniqueDay() then
                        return quest:event(348)
                    elseif quest:getMustZone(player) then
                        return quest:event(348)
                    end

                    return quest:progressEvent(349)
                end,
            },

            onEventFinish =
            {
                [349] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [351] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                end,

                [353] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.BUCKET_OF_COMPOUND_COMPOST)
                    quest:setVar(player, 'Prog', 0)
                    quest:setVar(player, 'Day', VanadielUniqueDay())
                    npcUtil.giveItem(player, xi.item.DANCE_SHOES)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_STERLING_SPECIMEN)
                end,
            },
        },
    },
}

return quest
