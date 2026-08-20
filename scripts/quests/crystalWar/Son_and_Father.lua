-----------------------------------
-- Son and Father
-----------------------------------
-- Log ID: 7, Quest ID: 57
-- Exoroche : Southern San d'Oria [S] (K-9)
-- Landeric : Jugner Forest [S] (G-5)
-----------------------------------
-- Retail (bg-wiki "Son and Father"), previous quest Father and Son:
--   1. Speak to Exoroche, Southern San d'Oria [S] (K-9) -- a boy who has lost
--      his father -- and accept.
--   2. Speak to Landeric, Jugner Forest [S] (G-5).
--   3. Return to Exoroche to receive a Bronze Sword.
--   4. Trade the Bronze Sword back to Exoroche.
--   5. Trade the Bronze Sword to Landeric (a four-choice sequence).
--   6. Return to Exoroche -> Trainee's Spectacles.
--
-- CSIDs decoded, not guessed. Exoroche is entity 17105322
-- (sql/npc_list.sql:8108); (17105322-16777216) = 328106, 328106//4096 = 80
-- rem 426 -> Southern San d'Oria [S]. Resolved with xidat/csidmsg.py and read
-- against `xi-dat dialog 80`. He owns exactly 156-164:
--   156 -> 7583 alone, the PRE-quest standing dialog.
--   157 -> 7583, 7584, 7588, 7589 -- the START. It is the only csid in the block
--          carrying msg 7584, "Help the boy find his father? ${selection-lines}
--          Of course! / Find him yourself.", which is the accept/decline prompt
--          and therefore the definitive start marker.
--   158 -> 7588, 7589, the quest-active reminder ("The child is too distraught
--          to provide you with any information.").
--   159 / 161 / 162 / 163 -> the Landeric and Bronze Sword steps and the reward.
--
-- Crystal War zones are NOT dialog-offset; zone 80's own table reads correctly.
--
-- The previous stub fired csid 1170, which `xi-dat csid 80 1170` reports as
-- "not found in zone 80" -- part of a fabricated arithmetic sequence keyed to the
-- quest id, so triggering Exoroche did nothing at all.
--
-- STILL SIMPLIFIED: the Bronze Sword hand-off loop (steps 3-5, csids 159/161/162/
-- 163) is not wired. Those ids are identified by position within Exoroche's block
-- rather than by a dialog match, so they are deliberately not shipped as fact.
-- What is faithful here: the correct start NPC and csid, the Father and Son
-- prerequisite, the Landeric visit, and the Trainee's Spectacles reward.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SON_AND_FATHER)

quest.reward =
{
    item = xi.item.TRAINEES_SPECTACLES,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                -- MY BUG, fixed: I wrote this prerequisite against the crystalWar
                -- table, but Father and Son is a SAN D'ORIA quest (id 4, in the
                -- xi.questLog.SANDORIA block of quests.lua, implemented at
                -- scripts/quests/sandoria/Father_and_Son.lua). There is no
                -- FATHER_AND_SON in the crystalWar table, so this resolved to nil
                -- and was passed as the uint16 questID argument of
                -- hasCompletedQuest -- a sol2 type error, not a failed check, so
                -- the quest could not even be offered.
                player:hasCompletedQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.FATHER_AND_SON)
        end,

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Exoroche'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(157)
                end,
            },

            onEventFinish =
            {
                -- 7584 is the accept/decline prompt: "Of course!" / "Find him
                -- yourself." Only option 0 accepts.
                [157] = function(player, csid, option, npc)
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

        [xi.zone.SOUTHERN_SAN_DORIA_S] =
        {
            ['Exoroche'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(163)
                    end

                    return quest:event(158)
                end,
            },

            -- COMPLETION CSID CORRECTED 159 -> 163. Both are real programs on
            -- Exoroche (0x010501AA = 17105322, zone 80), but 159 is 644 bytes and
            -- is bg-wiki's step 3 -- the father arriving, scolding, and handing
            -- over the sword. 163 is 1087 bytes and is the only one of Exoroche's
            -- block whose bytecode carries the `qstc` quest-complete opcode
            -- (`...455C80F8FFFF7FF8FFFF7F71737463` -- 71 73 74 63 = "qstc"); its
            -- messages 7611-7613 are the reward scene: "Father...", "She's a
            -- beauty, is she not? My hard-won catch of the day!", "And I believe
            -- this is yours as well." Completing on 159 fired the reward at the
            -- wrong point in the scene.
            onEventFinish =
            {
                [163] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },

        [xi.zone.JUGNER_FOREST_S] =
        {
            -- LANDERIC CSID CORRECTED 161 -> 222. `xi-dat csid 82 161` reports
            -- "not found in zone 82" -- 161 does not exist in Jugner Forest [S] at
            -- all; the 156-164 run belongs to Exoroche in zone 80, so this step
            -- was simply dead. Landeric's real event is 222: a 1213-byte program
            -- on the holder 0x01052317 (17113879) with the usual stub on the NPC,
            -- and its dialog 8013 is exactly bg-wiki's option list --
            -- "Ask for fishing advice. / Ask about Exoroche."
            ['Landeric'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 0 then
                        return quest:progressEvent(222)
                    end
                end,
            },

            onEventFinish =
            {
                [222] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },
}

return quest
