-----------------------------------
-- Puppetmaster Blues
-----------------------------------
-- Log ID: 6, Quest ID: 29
-- PUP AF3. Iruki-Waraki : Aht Urhgan Whitegate (K-9) !pos 101.329 -6.999 -29.042 50
-- Shamarhaan            : Bastok Markets (F-9)
-- ???                   : Mount Zhayolm (L-8)
-- Sajhra                : Nashmau (H-9)
-----------------------------------
-- Retail (bg-wiki "Puppetmaster Blues"). Level 50+ Puppetmaster.
-- Previous: Operation Teatime. Next: Achieving True Power.
-- Reward: Puppetry Taj. Title: Paragon of Puppetmaster Excellence.
--   1. Speak with Iruki-Waraki -> cutscene, he asks you to consult his mentor
--      Shamarhaan.
--   2. Bastok Markets, Shamarhaan (F-9) -> cutscene, {KI} Valkeng's memory chip,
--      and he tells you to fetch an item from Mount Zhayolm.
--   3. Mount Zhayolm (L-8): investigate the ??? on a round steam vent on the
--      ground -> {KI} Toggle switch.
--   4. With both key items, Talacca Cove -> battlefield vs Valkeng, Shamarhaan's
--      old military automaton.
--   5. Return to Shamarhaan -> cutscene.
--   6. Return to Iruki-Waraki in Aht Urhgan Whitegate -> cutscene.
--   7. Nashmau, Sajhra (H-9) on the docks -> cutscene.
--   8. Return to Iruki-Waraki -> final cutscene and the Puppetry Taj.
--
-- THE PREVIOUS VERSION WAS ENTIRELY FABRICATED. It carried no csid at all --
-- every line was an invented `printToPlayer` -- and it stopped at step 4, so
-- steps 5 through 8 (both return cutscenes and the whole Nashmau leg) did not
-- exist. It also bound `['Valkeng']` in Mount Zhayolm, and Valkeng is not an NPC
-- there at all: he is the battlefield MOB in Talacca Cove. The three Valkeng
-- npc_list rows live in zones 57, 64 and 235, none in 61, so that binding could
-- never fire and the Toggle switch was unobtainable.
--
-- CSIDs DECODED, NOT GUESSED.
--
-- Shamarhaan, Bastok Markets, entity 17739926 (npc_list:27862);
-- (17739926-16777216) = 962710, 962710//4096 = 235 rem 150 -> 0x010EB096. He owns
-- 433-444. Two of those are pinned by HARD EXTERNAL PROOF: Lamepaue, the Bastok
-- Markets "Past Event Watcher" (scripts/zones/Bastok_Markets/npcs/Lamepaue.lua),
-- replays finished cutscenes by quest, and its own table reads
--   option 72 -> Puppetmaster Blues (pt.1) -> startEvent(437)
--   option 73 -> Puppetmaster Blues (pt.2) -> startEvent(439)
-- so 437 and 439 are this quest's two Bastok Markets cutscenes, from the repo's
-- own replay NPC rather than from inference. (Lamepaue also gives 434 = No
-- Strings Attached and 441 = Achieving True Power, which is why those are not
-- used here.) Both sit on the zone holder 0x7FFFFFF0 -- 1243 and 4973 bytes --
-- with 1-byte 0x00 stubs on Shamarhaan, the usual holder/stub layout.
-- The neighbours were read against `xi-dat dialog 235`:
--   438 -> 9581, 9582 (+843, 844, 9589)  the REMINDER. It reuses pt.1's two
--          instruction lines verbatim:
--          9581 "If you want to prove that you're worthy, take
--               ${keyitem-singular: 0[2]} and go to Talacca Cove on the Arrapago
--               Islands."
--          9582 "Ah, but before that you'll also need a ${keyitem-singular: 1[2]}.
--               The Trolls used to use them during construction, so you might be
--               able to find one on Mount Zhayolm."
--          Those two ${keyitem-singular} slots are why 437 and 438 are passed
--          param 0 = Valkeng's memory chip and param 1 = Toggle switch.
--   440 -> 9702-9704  "You should go back to Iruki-Waraki now." / "Cheer him up
--          for me, will you?" -- so 440 is the nudge AFTER 439, not a post-quest
--          idle. It sits between 439 and Achieving True Power's 441.
--
-- Iruki-Waraki, Aht Urhgan Whitegate, entity 16982325 (npc_list:4304);
-- (16982325-16777216) = 205109, 205109//4096 = 50 rem 309 -> 0x01032135. His
-- event table lists 782-787 as one contiguous block immediately after the
-- Operation Teatime block (778-781), and `xi-dat csid 50 <n>` shows a clean
-- alternation of the documented holder/stub pattern:
--   782  422 bytes on holder 0x01032134, 1-byte 0x00 stub on Iruki  CUTSCENE
--   783  10 bytes ON Iruki, 0x1D..0x1D only                         2-line chat
--   784  639 bytes on holder 0x01032134, stub on Iruki              CUTSCENE
--   785  6 bytes ON Iruki, single 0x1D                              1-line chat
--   786  520 bytes on holder 0x01032134, stub on Iruki              CUTSCENE
--   787  14 bytes ON Iruki, three 0x1D                              3-line chat
-- Three cutscenes and three chat stubs is exactly the shape of the walkthrough:
-- offer, reminder, mid-quest cutscene, reminder, final cutscene, post-quest idle.
-- His own text refs are computed rather than literal, so csidmsg cannot quote
-- them; the assignment rests on the block's position and the holder/stub sizes,
-- which is why it is spelled out here rather than presented as quoted dialog.
--
-- Sajhra, Nashmau, entity 16994321 (npc_list:4951); (16994321-16777216) = 217105,
-- 217105//4096 = 53 rem 17 -> 0x01035011. She owns 220, 290, 291, 312.
-- csidscan against the zone holder resolves both big ones, and 291 is ours:
--   291 -> 10970-11119, which contains the confrontation and its 3-way prompt
--          11080 "What do you wanna tell me? ${selection-lines} Why Iruki is a
--                great puppetmaster. / A puppetmaster's greatest possession. /
--                Elisabeth's secret to success."
--          11100 "Iruki-Waraki is the best puppetmaster in Al Zahbi...no, in all
--                of the Aht Urhgan Empire!"
--          11105 "Ellie...?"  11111 "Ellie..."  11113 "Let's go back to Al Zahbi."
--          That closing line is what sets up the final Whitegate cutscene.
--          bg-wiki notes the choice does not affect the outcome, so no option is
--          tested.
--   290 -> 10900-11081 is OPERATION TEATIME, not this quest -- 10902 "let me show
--          you around", 10905 "This is the port", 10907 "Tea? I don't remember
--          there being a teahouse here in Nashmau..." Excluded deliberately.
--   220 is her Nashmau docks ferry prompt and is left to the legacy
--   scripts/zones/Nashmau/npcs/Sajhra.lua, which handles only 220.
--
-- THE MOUNT ZHAYOLM ??? IS qm8, entity 17027569, npc_list:5736, at
-- (760.798, -14.972, 1.656), status 0 so it already renders. Zone 61 has twelve
-- ??? rows and only qm1-qm5 had scripts (all ZNM pop points), so the right one
-- had to be identified rather than picked. bg-wiki gives its position as (L-8),
-- and the zone's map grid was solved from five independent anchors -- the ZNM
-- pop points whose grid refs bg-wiki's Mount Zhayolm page states beside their
-- names, checked against the `!pos` in each qm script:
--   Anantaboga  (-368, 366) E-6      Khromasoul   (88,  70)  G-7/8
--   Brass Borer ( 399, 120) I-7      Claret       (497, 52)  J-8
--   Sarameya    ( 322,-581) I-12
-- All five fit one grid: 160 units per cell, letters increasing with +X from
-- x0 in (-1032, -1008], numbers increasing as Z DECREASES from z0 in (1179, 1240].
-- Under every parameter value in those ranges qm8 lands in L-8 uniquely, while
-- qm6 (848.9, 316.6) is L-6 and qm7 (841.0, 247.0) is L-6/L-7. The same solution
-- reproduces the two anchors it was not pinned by, qm1 -> I-7 and qm5 -> I-12.
-- qm8 owns NO event program -- it is absent from `xi-dat events 61`, and zone 61
-- has no "toggle", "switch" or "steam vent" dialog -- so the key item is handed
-- over directly with no cutscene, which is what an eventless ??? does.
--
-- FAME: bg-wiki's header says `Fame=AU` with no amount. There is no Aht Urhgan
-- fame area -- scripts/enum/fame_area.lua mirrors CLuaBaseEntity::addFame() and
-- stops at Adoulin -- so AU fame cannot be granted here at all. The old stub
-- awarded `fameArea = NORG, fame = 30`, which is a different region entirely and
-- would have inflated Norg fame and loosened unrelated Norg gates. 59 of the 66
-- Aht Urhgan quests grant no fame and the other 6 use WINDURST (the mapped area
-- for Mhaura and Kazham); this one was the sole NORG outlier. No fame is granted
-- rather than granting it to the wrong region.
--
-- KEY ITEMS ARE CONSUMED BY THE BATTLEFIELD, not here. battlefield.lua:408 --
-- "requiredKeyItems ... are removed upon entry unless 'keep = true'" -- and
-- scripts/battlefields/Talacca_Cove/puppetmaster_blues.lua declares both without
-- `keep`. The old stub deleted them a second time on mob death. That also means
-- a party that ENTERS AND LOSES comes out holding neither, so both sources stay
-- open for the whole pre-win stage: Shamarhaan's 438 re-issues the memory chip
-- and the ??? re-issues the toggle switch. Without that a single wipe would have
-- made the quest unfinishable.
--
-- The battlefield itself already existed and is unchanged; the win is picked up
-- through the standard 32001 / `battlefieldWin` hook, the same way the sibling
-- AF4 quest scripts/quests/bastok/Achieving_True_Power.lua does it.
--
-- NOT TOUCHED: scripts/zones/Aht_Urhgan_Whitegate/npcs/Iruki-Waraki.lua, the
-- legacy script that still drives No Strings Attached, The Wayward Automaton and
-- Operation Teatime on csids 267 and 774-781. None of those overlap 782-787, and
-- onTrigger is one of the three handlers interaction_lookup excludes from
-- double-dispatch, so the two coexist. Every `check` below additionally requires
-- Operation Teatime to be COMPLETE, so this quest cannot shadow the earlier ones.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PUPPETMASTER_BLUES)

quest.reward =
{
    item  = xi.item.PUPPETRY_TAJ,
    title = xi.title.PARAGON_OF_PUPPETMASTER_EXCELLENCE,
}

-- 437 and 438 both render ${keyitem-singular: 0[2]} and ${keyitem-singular: 1[2]}.
local shamarhaanKeyItems =
{
    [0] = xi.ki.VALKENGS_MEMORY_CHIP,
    [1] = xi.ki.TOGGLE_SWITCH,
}

quest.sections =
{
    -- Iruki-Waraki asks you to go and see his mentor. Level and job are retail
    -- requirements; Operation Teatime is the stated Previous quest.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.OPERATION_TEATIME) and
                player:getMainJob() == xi.job.PUP and
                player:getMainLvl() >= xi.settings.main.AF3_QUEST_LEVEL
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(782)
                end,
            },

            onEventFinish =
            {
                [782] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Off to Bastok Markets. Shamarhaan hands over the memory chip and names
    -- Mount Zhayolm as the source of the toggle switch.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] = quest:event(783),
        },

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Shamarhaan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(437, shamarhaanKeyItems)
                end,
            },

            onEventFinish =
            {
                [437] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.VALKENGS_MEMORY_CHIP)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- Gather both key items and beat Valkeng. Everything in this stage stays
    -- available until the battlefield is actually won, because entering consumes
    -- both key items whether or not the fight is survived.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] = quest:event(783),
        },

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Shamarhaan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(438, shamarhaanKeyItems)
                end,
            },

            onEventFinish =
            {
                [438] = function(player, csid, option, npc)
                    if not player:hasKeyItem(xi.ki.VALKENGS_MEMORY_CHIP) then
                        npcUtil.giveKeyItem(player, xi.ki.VALKENGS_MEMORY_CHIP)
                    end
                end,
            },
        },

        -- The ??? owns no event program, so the key item is handed straight over.
        [xi.zone.MOUNT_ZHAYOLM] =
        {
            -- qm8, entity 17027569, the ??? on the steam vent at (L-8).
            ['qm8'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.TOGGLE_SWITCH) then
                        npcUtil.giveKeyItem(player, xi.ki.TOGGLE_SWITCH)
                    end
                end,
            },
        },

        [xi.zone.TALACCA_COVE] =
        {
            onEventFinish =
            {
                [32001] = function(player, csid, option, npc)
                    if player:getLocalVar('battlefieldWin') == xi.battlefield.id.PUPPETMASTER_BLUES then
                        quest:setVar(player, 'Prog', 2)
                    end
                end,
            },
        },
    },

    -- Valkeng is down: report back to Shamarhaan.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 2
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Shamarhaan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(439)
                end,
            },

            onEventFinish =
            {
                [439] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 3)
                end,
            },
        },
    },

    -- 440 is Shamarhaan's "You should go back to Iruki-Waraki now."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 3
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Shamarhaan'] = quest:event(440),
        },

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(784)
                end,
            },

            onEventFinish =
            {
                [784] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },
    },

    -- Nashmau. The prompt in 291 has three answers and bg-wiki states none of
    -- them changes the outcome, so option is not inspected.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 4
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] = quest:event(785),
        },

        [xi.zone.NASHMAU] =
        {
            ['Sajhra'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(291)
                end,
            },

            onEventFinish =
            {
                [291] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 5)
                end,
            },
        },
    },

    -- Back to Iruki-Waraki for the Puppetry Taj.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 5
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(786)
                end,
            },

            onEventFinish =
            {
                [786] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },

    -- 787, his post-quest idle.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Iruki-Waraki'] = quest:event(787),
        },
    },
}

return quest
