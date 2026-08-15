-----------------------------------
-- Babban Ny Mheillea
-----------------------------------
-- Log ID: 2, Quest ID: 95
-- Khoto Rokkorah      : Windurst Waters (North) (H-10)
-- Peculiar Rootprints : Rolanberry Fields [S] (H-14)
--                       North Gustaberg [S] (E-11)
--                       Meriphataud Mountains [S] (L-4)
-----------------------------------
-- Retail (bg-wiki "Babban Ny Mheillea"), not repeatable:
--   1. Speak to Khoto Rokkorah -> cutscene, quest begins.
--   2. Touch the Peculiar Rootprints in Rolanberry Fields [S] (H-14).
--   3. Then North Gustaberg [S] (E-11).
--   4. Then Meriphataud Mountains [S] (L-4), near the Sanctuary of Zi'Tah
--      zoneline.
--   5. Return to Khoto Rokkorah -> final cutscene, 3x Bag of Tree Saplings and
--      the title Babban's Traveling Companion.
--
-- THE ORDER IS FIXED, NOT FREE. The old stub's header claimed the three
-- rootprints could be touched "in any order", and implemented them as three
-- independent zone-in bitmask flags. The dumps disprove that: each rootprint's
-- final lines name the NEXT zone, so they form a chain.
--
-- CSIDs decoded, not guessed. Khoto Rokkorah is entity 17752345
-- (npc_list:29070); (17752345-16777216) = 975129, 975129//4096 = 238 rem 281 ->
-- Windurst Waters, 0x010EE119. Read against `xi-dat dialog 238`:
--   988 -> 15077 "Hello! Have you come to hear a tale?", 15078 "I'm a
--          storyteller, and I often entertain the children here with fantastic
--          yarns and magical myths." -- the pre-quest greeting.
--   989 -> the quest-start cutscene, the story reading. A 946-byte program on the
--          invisible holder 'blank' 0x010EE116 (17752342), with 1-byte stubs on
--          Khoto 0x010EE119, on Tihk Rhumyie 0x010EE11A (17752346) and on ~12
--          child actors. Its sub-narration is csid 1015 (871 bytes, same holder)
--          -> 15089-15103: 15086 "Ahem. 'The Adventures of Babban Ny
--          Mheillea...'", 15089 "Her name was Babban Ny Mheillea.", 15090 "She
--          was traveling in search of the great plant city 'Netherstalk,'"
--   990 -> a 95-byte program on Khoto -> data[0x0F]=15122, [0x10]=15123,
--          [0x11]=15124. 15122 "I still can't get 'The Adventures of Babban Ny
--          Mheillea' out of my mind.", 15124 "Could this fable be based on a true
--          story...?" -- THE IN-PROGRESS REMINDER.
--   991 -> the completion cutscene, 4378 bytes on 'blank' 0x010EE116 with stubs
--          on Khoto, Tihk Rhumyie and ~24 actors -- the largest actor set in the
--          zone. csidmsg -> 15129-15132; 15128 "Are we all comfortable? Then let
--          us continue with 'The Adventures of Babban Ny Mheillea'...", 15149
--          "W-was that the real Babban Ny Mheillea!?", 15152 "That's what they
--          called the sapling!", 15155 "Hehe, that's an amazing coincidence.
--          Wouldn't it be wonderful if that sapling was really you...?" The
--          second-half narration is the sub-scene csid 1016 (1548 bytes).
--   992 -> a 69-byte program on Khoto -> data[0x13]=15156, [0x14]=15157.
--          15157 "Just you wait! One day I'll be the best storyteller this town
--          has ever seen!" -- post-completion idle.
--
-- CRITICAL FIX: the stub used csid 990 -- the in-progress REMINDER -- as the
-- completion event. The real completion is 991. It got the start (989) right.
--
-- The three rootprints, each pinned by its own hand-off line naming the next
-- zone, which is what proves the ordering:
--   Rolanberry Fields [S], zone 91: Rootprints are 17150797 -> 373581//4096 = 91
--     rem 845, 0x0105B34D, which owns ONLY the 65535 sentinel. The program sits
--     two indices earlier on the 'blank' holder 0x0105B34B (17150795), 2598
--     bytes, and resolves zone-wide. csidmsg 91 17150795 -> 5 -> 7958, 7959,
--     7976-7978, 7992. 7958 "Babban and her friends continued in their search
--     for the fabled city of Netherstalk...", 7966 "Fair day to you, my sapling
--     friend! My name is Babban Ny Mheillea.", and 7992 "Taking the advice of the
--     confident Camlin, our intrepid plant pilgrims set off south across the
--     rocky plains of GUSTABERG..." -- which hands off to rootprint 2. Examine
--     text 7993 "It appears that various roots and vines have been dragged
--     through this area..."
--   North Gustaberg [S], zone 88: Rootprints 17138503, 0x01058347, owns csid 114
--     directly; the 2843-byte program is on 'blank' 0x01058345 (17138501).
--     csidmsg 88 17138501 -> 114 -> 7792, 7793, 7800, 7811, 7812. 7811 "What
--     adventures await our valiant voyagers beyond the northeastern boundary of
--     the MERIPHATAUD MOUNTAINS?", 7812 "Will they finally discover the elusive
--     city of Netherstalk...?" -- hands off to rootprint 3.
--   Meriphataud Mountains [S], zone 97: Rootprints 17175346, 0x01061332, owns
--     csid 105 directly; the 5361-byte program is on 'blank' 0x01061330
--     (17175344). csidmsg 97 17175344 -> 105 -> 7812, 7813, 7819, 7825, 7835,
--     7839, 7850, 7851, 7852. 7850 "And so, Babban and her fellow travelers set
--     out upon their quest with renewed vigor.", 7852 "The details of that grand
--     adventure will have to wait until the next exciting chapter..." -- the final
--     chapter, so this is rootprint 3.
--
-- All three Rootprints exist with status 0: npc_list:10367 (zone 91),
-- :9828 (zone 88), :11604 (zone 97). Every cutscene actor is present too --
-- Babban_Ny_Mheillea, Abenzio and Bryher in all three zones (17150798-17150800,
-- 17138504-17138506, 17175347-17175349), plus Camlin 17175350 in zone 97 and
-- Tihk_Rhumyie 17752346 in Windurst Waters. Nothing needed adding to npc_list.
--
-- bg-wiki lists no fame, so the stub's 30 is gone. 3x Bag of Tree Saplings
-- (xi.item.BAG_OF_TREE_SAPLINGS = 1238) and the title (595) are both retail.
-----------------------------------
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.BABBAN_NY_MHEILLEA)

quest.reward =
{
    item  = { { xi.item.BAG_OF_TREE_SAPLINGS, 3 } },
    title = xi.title.BABBANS_TRAVELING_COMPANION,
}

-- Ordered: each rootprint's closing narration names the next zone.
local rootprints =
{
    { zone = xi.zone.ROLANBERRY_FIELDS_S,      csid =   5 },
    { zone = xi.zone.NORTH_GUSTABERG_S,        csid = 114 },
    { zone = xi.zone.MERIPHATAUD_MOUNTAINS_S,  csid = 105 },
}

local function rootSection()
    local section =
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Chapter < #rootprints
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] = quest:event(990),
        },
    }

    for chapter, root in ipairs(rootprints) do
        section[root.zone] =
        {
            ['Peculiar_Rootprints'] =
            {
                onTrigger = function(player, npc)
                    -- Only the next rootprint in the chain responds.
                    if quest:getVar(player, 'Chapter') ~= chapter - 1 then
                        return quest:messageSpecial(zones[root.zone].text.NOTHING_OUT_OF_ORDINARY)
                    end

                    return quest:progressEvent(root.csid)
                end,
            },

            onEventFinish =
            {
                [root.csid] = function(player, csid, option, npc)
                    if quest:getVar(player, 'Chapter') == chapter - 1 then
                        quest:setVar(player, 'Chapter', chapter)
                    end
                end,
            },
        }
    end

    return section
end

quest.sections =
{
    -- 988 greeting, 989 the story reading that begins the quest.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(989)
                end,
            },

            onEventFinish =
            {
                [989] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    rootSection(),

    -- All three chapters read: back to Khoto Rokkorah for 991.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Chapter >= #rootprints
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(991)
                end,
            },

            onEventFinish =
            {
                [991] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },

    -- 15156 / 15157, post-completion idle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] = quest:event(992),
        },
    },
}

return quest
