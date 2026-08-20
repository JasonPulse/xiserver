-----------------------------------
-- The Perils of Kororo
-----------------------------------
-- Log ID: 8, Quest ID: 66
-- Kororo         : Abyssea - Grauberg (H-13), entity 17818228
-- Eight_of_Clubs : Abyssea - Grauberg (H-8),  entity 17818229
-- !addquest 8 66
-----------------------------------
-- Retail (bg-wiki "The Perils of Kororo").
-- |Start=Kororo (A) (H-13), Abyssea - Grauberg
-- |Previous=Master Missing, Master Missed  |Reward=1,200 Cruor
--   "You do not need to zone after completing Master Missing, Master Missed to
--    start this quest."
--   1. Speak to Kororo (A) at (H-13), southwest of Conflux #2.
--   2. Talk to Eight of Clubs (A) at (H-8).
--   3. Return to Kororo (A).
--
-- CSIDS DECODED, NOT GUESSED, via csidmsg.load() on both blocks and find_msg
-- against `xi-dat dialog 254`:
--   Kororo (entries {206:1, 207:15, 204:45, 208:46, 217:75, 219:448, 220:477,
--   221:578}):
--     217 -> 8021-8032  THE OPENING CUTSCENE. 8021 "You think the Cardians'
--            memories were erased, and I'm the culprity?", 8024 explains she
--            erased them out of pity, 8026 "After I erased Eight of Clubs'
--            memory and returned to him his ${keyitem-singular: 0[2]}", and
--            8028-8032 bring Eight of Hearts into the scene.
--     219 -> 8038       THE TASK: "could you go and checky on Eight of Clubs as
--            well?" -- which is also the active reminder.
--     220 -> 8047-8053  THE COMPLETION. 8047 "Eight of Clubs said that? <Sigh>
--            This lifts a heavy weighty off my tiny Taru chest", through 8053
--            "This isn't much, but I want you to have it" -- the reward line.
--     221 -> 8054       her post-completion line.
--   Eight_of_Clubs (entries {209:1, 210:30, 211:77, 212:106, 213:161, 214:190,
--   215:449, 222:478, 223:554}):
--     222 -> 8041-8045  THE VISIT. 8043 "aLL MeMoRies of mAsteR, be TheY hAppY
--            oR SAd, Are tReaSUres to EighT of ClubS", closing on 8045 "PLeaSe
--            teLL Her tHat eIGHt of cLUBs Is fAriNG wEll" -- the message you
--            carry back.
--     223 -> 8046       the same request on later visits.
--   His 214 (8001-8012) and 215 (8020) belong to Master Missing, Master Missed,
--   the preceding quest, and are deliberately untouched here.
--
-- PROGRESS uses a single 'Visited' var rather than a mask -- there is only one
-- Cardian to see.
--
-- CHAIN NOTE: |Previous= is Master Missing, Master Missed (abyssea 65), which is
-- not implemented yet. The gate below is correct per bg-wiki; that quest, and
-- The Mysterious Head Patrol (64) before it, still need building for this to be
-- reachable in a fresh playthrough.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_PERILS_OF_KORORO)

local cruorReward = 1200

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MASTER_MISSING_MASTER_MISSED)
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Kororo'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(217)
                end,
            },

            onEventFinish =
            {
                [217] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: go and look in on Eight of Clubs.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Visited == 0
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Clubs'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(222)
                end,
            },

            ['Kororo'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(219)
                end,
            },

            onEventFinish =
            {
                [222] = function(player, csid, option, npc)
                    quest:setVar(player, 'Visited', 1)
                end,
            },
        },
    },

    -- Carry his message back to Kororo.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Visited == 1
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Kororo'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(220)
                end,
            },

            ['Eight_of_Clubs'] = quest:event(223),

            onEventFinish =
            {
                [220] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Visited', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Kororo'] = quest:event(221):replaceDefault(),
        },
    },
}

return quest
