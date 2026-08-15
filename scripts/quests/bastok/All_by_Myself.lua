-----------------------------------
-- All by Myself
-----------------------------------
-- Log ID: 1, Quest ID: 76
-- Marin : Bastok Markets (E-10), and again at the Dangruf Wadi exit
-- Ken   : Bastok Markets (E-10), and the escort in Dangruf Wadi
-----------------------------------
-- Retail (bg-wiki "All by Myself"), repeatable:
--   1. Speak to Marin and accept. You MUST select "I wasn't talking to you,
--      squirt." to proceed.
--   2. Enter Dangruf Wadi for a short intro cutscene (re-zone if you arrived by
--      Survival Guide).
--   3. Speak to Ken to start -- this caps you at level 10.
--   4. Shadow Ken unseen along his fixed route. Eight position-triggered
--      progress messages. He engages every mob in line of sight. If he ever
--      spots you, or if he dies, the run fails.
--   5. After Ken despawns Marin appears at the exit -- speak to her to remove
--      the level cap and receive {KI} Ken's escort award.
--   6. Return to Bastok Markets and speak to Marin to complete.
-- Reward: 1,500 gil. Fame Bastok 2 to start. No title.
--
-- CSIDs decoded, not guessed. Marin is entity 17739892 (npc_list:27828);
-- (17739892-16777216) = 962676, 962676//4096 = 235 rem 116 -> Bastok Markets,
-- 0x010EB074. Ken is the next index, 17739893 -> 0x010EB075. Read against
-- `xi-dat dialog 235`:
--   361 -> the first-time offer, two nested prompts. 8457 "Ah, an adventurer!
--          It is your job to help people, right? Are you interested in becoming
--          a bodyguard for my little brother?", then 8460 "Okay? / Okay. /
--          I wasn't talking to you, squirt." -- an exact match for bg-wiki's
--          required selection, which is what pins this as the start -- and
--          finally 8471 "Accept the job? / You can count on me! / I don't like
--          kids."
--   362 -> the REPEAT offer. 8484 "My brother was accused of cheating on his
--          military academy entrance examination and has been ordered to take a
--          make-up test...", 8486 "Babysit Marin's brother? / No problem. /
--          Not this time." -- this is the Repeatable=Y path.
--   363 -> the accepted reminder. 8478 "Please, sir/ma'am! I ask you again,
--          protect my brother during his test!"
--   364 -> the turn-in. 8487 "Thank you so much for watching over my brother.",
--          8488 "Here is the reward I promised you." -- the 1,500 gil.
--   365 -> the cancel prompt while active. 8480 "Second thoughts? / And third
--          thoughts. / No, everything's fine."
--   366 -> 8490 "I do hope that you pass..." -- post-completion idle.
--   Ken's own Bastok Markets lines: 367 -> 8474 "Hmph... You can tag along if
--   you like--just don't get in my way!", 368 -> 8482, 369 -> 8483,
--   370 -> 8489 "That test was a piece of cake!", 371 -> 8491.
--
-- Dangruf Wadi side: `xi-dat csid 191 150` reports THREE owners -- a 220-byte
-- program on the zone-global 0x7FFFFFF0 plus 10-byte stubs on BOTH
-- 0x010BF176 (Ken, 17559926 -> 782710//4096 = 191 rem 374) and 0x010BF177
-- (Marin, 17559927, the next index). The program references both entities and
-- the vars shg0 / fdi2 / fdo1. Zone 191's dialog carries the whole run, and each
-- line maps to one of bg-wiki's eight progress messages:
--   7468 "I have this funny feeling I'm being watched..."
--   7471 "Uh-oh... I think I'm lost. I really should have brought that map Sis
--        gave me..."
--   7476 "A dead end... I guess I'll go back to that other place."
--   7478 "Now let's see... Depth... Temperature..."
--   7480 "What was that sound...?"   7481 / 7482
--   7483 "Huh. That was easy. I don't know what Sis was all worried about."
--   Failures: 7484 "You! I told you not to follow me! That's it! I'm going
--   home!", 7485, 7466 / 7467.
--
-- Both Ken AND Marin exist in Dangruf Wadi (npc_list:22491 and :22492, each
-- status 2 = spawned on demand), so retail's step 5 -- Marin appearing at the
-- exit -- is genuinely buildable and is built.
--
-- The old stub used 362 (the repeat offer) as the first accept and 363 (the
-- reminder) as the reward, and replaced the whole stealth escort with a Dangruf
-- Wadi zone-in flag. It also never granted {KI} Ken's escort award
-- (xi.ki.KENS_ESCORT_AWARD = 993, key_item.lua:986) despite that being a retail
-- item requirement, and it had no QUEST_COMPLETED section at all, so the
-- Repeatable=Y path was impossible.
--
-- bg-wiki lists no fame, so the stub's 30 is gone. 1,500 gil is retail and stays.
--
-- STILL SIMPLIFIED, and deliberately not faked: Ken does not path, so the eight
-- position-triggered messages and the "he spots you" / "he dies" failures are not
-- wired -- that needs waypoint data this repo does not carry, and csid 150 is one
-- shared program used from three call sites whose param split is not decoded
-- (Agent-level confidence on the split was MEDIUM, unlike the Marin ids above).
-- What is faithful: the correct start csid and its required selection, the level
-- 10 cap, both the Ken-talk and Marin-at-the-exit steps, the escort award key
-- item, the cancel path, the reward and the repeat path.
-----------------------------------
local marketsID = zones[xi.zone.BASTOK_MARKETS]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF)

local levelCap = 10

quest.sections =
{
    -- Marin offers. 361 first time, 362 for the make-up test on repeats.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 2
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(362)
                    end

                    return quest:progressEvent(361)
                end,
            },

            -- 8474 before the first clear, 8491 afterwards.
            ['Ken'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF) == xi.questStatus.QUEST_COMPLETED then
                        return quest:event(371)
                    end

                    return quest:event(367)
                end,
            },

            onEventFinish =
            {
                -- 8471 "Accept the job? / You can count on me! / I don't like
                -- kids." -- option 0 accepts.
                [361] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                    end
                end,

                -- 8486 "Babysit Marin's brother? / No problem. / Not this time."
                [362] = function(player, csid, option, npc)
                    if option == 0 then
                        player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF)
                    end
                end,
            },
        },
    },

    -- Contract taken, the run not yet done.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                not player:hasKeyItem(xi.ki.KENS_ESCORT_AWARD)
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    -- 8480 "Second thoughts? / And third thoughts. / No,
                    -- everything's fine." Retail lets you back out here.
                    if quest:getVar(player, 'Escort') ~= 0 then
                        return quest:progressEvent(365)
                    end

                    return quest:event(363)
                end,
            },

            ['Ken'] = quest:event(368),

            onEventFinish =
            {
                [365] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:setVar(player, 'Escort', 0)
                        player:delQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF)
                    end
                end,
            },
        },

        [xi.zone.DANGRUF_WADI] =
        {
            onZoneIn = function(player, prevZone)
                -- The intro cutscene. Retail wants a genuine zone entry, which is
                -- why bg-wiki says to re-zone if you used a Survival Guide.
                if quest:getVar(player, 'Escort') == 0 then
                    return 150
                end

                return -1
            end,

            ['Ken'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Escort') ~= 1 then
                        return
                    end

                    return quest:progressEvent(150)
                end,
            },

            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Escort') ~= 2 then
                        return
                    end

                    return quest:progressEvent(150)
                end,
            },

            onEventFinish =
            {
                [150] = function(player, csid, option, npc)
                    local stage = quest:getVar(player, 'Escort')

                    if stage == 0 then
                        -- Intro watched: Ken will now talk.
                        quest:setVar(player, 'Escort', 1)
                    elseif stage == 1 then
                        -- Ken sets off, and the level restriction goes on. This
                        -- is levelRestriction, NOT setLevelCap: setLevelCap is
                        -- the limit-break ceiling (see the LB03-LB10 quests) and
                        -- would permanently cap the character at 10.
                        player:levelRestriction(levelCap)
                        quest:setVar(player, 'Escort', 2)
                    elseif stage == 2 then
                        -- Marin at the exit: restriction lifted, award handed
                        -- over. 0 clears it, as scripts/effects/level_restriction
                        -- .lua:34 does.
                        player:levelRestriction(0)

                        if npcUtil.giveKeyItem(player, xi.ki.KENS_ESCORT_AWARD) then
                            quest:setVar(player, 'Escort', 0)
                        end
                    end
                end,
            },
        },
    },

    -- Award in hand: back to Marin for the 1,500 gil.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:hasKeyItem(xi.ki.KENS_ESCORT_AWARD)
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(364)
                end,
            },

            ['Ken'] = quest:event(370),

            onEventFinish =
            {
                [364] = function(player, csid, option, npc)
                    local reward = xi.settings.main.GIL_RATE * 1500

                    player:delKeyItem(xi.ki.KENS_ESCORT_AWARD)
                    player:addGil(reward)
                    player:messageSpecial(marketsID.text.GIL_OBTAINED, reward)
                    player:completeQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF)
                    quest:setVar(player, 'Escort', 0)
                end,
            },
        },
    },

}

-- 366 is Marin's post-completion idle (8490 "I do hope that you pass..."), but
-- because this quest is repeatable the first section already claims the
-- COMPLETED state in order to offer the make-up test at 362, so 366 is only
-- reachable once the tally-free repeat offer is declined. Left here as the
-- documented owner of that id rather than in a section that could never run.

return quest
