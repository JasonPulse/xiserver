-----------------------------------
-- Synergistic Pursuits
-----------------------------------
-- Log ID: 1, Quest ID: 89
-- Hildolf : Metalworks (F-8)
-----------------------------------
-- Retail (bg-wiki "Synergistic Pursuits"). Fame Bastok, FLevel 1.
-- Next: The Wondrous Whatchamacallit. Reward: {KI} Synergy crucible + the Synergy
-- ability.
--
-- IMPORTANT -- THIS QUEST WAS GRANDFATHERED. bg-wiki's own notes:
--   "It is no longer possible to flag this quest. Speak to a Synergy Engineer to
--    obtain a Synergy Crucible if you did not activate this quest prior to
--    March 27[, 2012]."
--   "Although the original quest has been removed along with its requirements,
--    speaking to Hildolf will still trigger a quest under the same title."
--   "The quest will show up in the log and be marked as completed upon completion
--    of Synergistic Support."
-- So the ORIGINAL four-component fetch is gone from retail, and the modern flow is
-- simply: speak to Hildolf, get the crucible. That is what is implemented here.
-- The original components are still visible in the dialog (see 7339-7342 below)
-- and are recorded for reference, but requiring them would be re-adding something
-- retail deleted.
--
-- WHY THIS MATTERS BEYOND THIS QUEST: this file is the repo's ONLY
-- `giveKeyItem(xi.ki.SYNERGY_CRUCIBLE)`. The retail alternative source, the Synergy
-- Engineer, is a bare DefaultActions entry here. So Synergistic Support and
-- The Wondrous Whatchamacallit both gate on a crucible that nothing else grants.
--
-- CSIDs DECODED, NOT GUESSED -- the previous version admitted "CSIDs best-guess"
-- and fired 700/701, which are not among the ten programs Hildolf owns.
-- Hildolf is entity 17748169 (npc_list:28753); (17748169-16777216) = 970953,
-- 970953//4096 = 237 rem 201 -> Metalworks, 0x010ED0C9. Resolved with
-- xidat/csidscan.py and read against `xi-dat dialog 237`:
--   964 -> 7319-7342  THE OFFER. 7319 "Welcome to the Bastokan Institute for
--          Synergistic Research. I am Hildolf, chairman and lead researcher.",
--          then TWO prompts, and in BOTH of them the accepting choice is the
--          SECOND one, i.e. option 1:
--            7321 "Learn about synergy? / Not now. / Of course!"
--            7334 "Become a synergist? / Maybe another time. / Sign me up!"
--          7336 "Wonderful! Another test subj--er, budding synergist! First, we'll
--          be needing to set you up with ${keyitem-article: 0[2]}."
--          (7339-7342 are the retired component list -- four ${item-article}
--          slots, described at 7340-7341 as two from "the worms that inhabit
--          Gustaberg", one from "the Palborough Mines", and one from "a good
--          goldsmith". Retired on retail; not required here.)
--   965 -> 7339-7343  the reminder: 7343 "What? You've forgotten which materials
--          you need? Tsk tsk."
--   966 -> 7344-7350  THE CRUCIBLE HAND-OVER. 7344 "Stupendous! Can hardly wait to
--          kick-start your career as a synergist, I see.", then 7345 "And there
--          you have it! Your very own ${keyitem-singular: 0[2]}, designed to be
--          compatible with any synergy furnace. And as an added bonus ... your
--          first fill-up of fewell is on the house!", 7346 points you at the
--          synergy engineers, 7347 at the Alchemists' Guild.
--   967 -> 7349  a single closing line.
-- The sibling file scripts/quests/bastok/Synergistic_Support.lua documents the
-- same entity's 973-978 block, which is that quest.
--
-- bg-wiki lists no fame value, so the old invented `fame = 30` is gone. The
-- crucible and the Synergy ability are the reward.
--
-- NOTE ON 7345's "first fill-up of fewell": retail hands over a starter fewell
-- supply with the crucible. The eight fewell item ids are known
-- (xi.item.ORB_OF_*_FEWELL, 2784-2791) but the wiki does not state which type or
-- how many, so nothing is granted rather than inventing a quantity.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS)

quest.reward =
{
    keyItem = xi.ki.SYNERGY_CRUCIBLE,
}

quest.sections =
{
    -- 7321 / 7334: both prompts accept on option 1.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                not player:hasKeyItem(xi.ki.SYNERGY_CRUCIBLE)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(964, { [0] = xi.ki.SYNERGY_CRUCIBLE })
                end,
            },

            onEventFinish =
            {
                [964] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Accepted: Hildolf builds the crucible. 966 is the hand-over.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SYNERGY_CRUCIBLE) then
                        return quest:event(967)
                    end

                    return quest:progressEvent(966, { [0] = xi.ki.SYNERGY_CRUCIBLE })
                end,
            },

            onEventFinish =
            {
                [966] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },

    -- 967, his closing line once you are a synergist.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] = quest:event(967),
        },
    },
}

return quest
