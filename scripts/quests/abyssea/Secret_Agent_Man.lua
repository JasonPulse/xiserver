-----------------------------------
-- Secret Agent Man
-----------------------------------
-- Log ID: 8, Quest ID: 18
-- Helga : Abyssea - Konschtat (G-5), entity 16839226
-- Naji  : Abyssea - Konschtat (J-5), entity 16839228
-- !addquest 8 18
-----------------------------------
-- Retail (bg-wiki "Secret Agent Man").
-- |Start=Helga (A) (G-5), Abyssea - Konschtat  |Previous=The Soul of the Matter
-- |Item Reqs={{KI}} Naji's gauger plate
-- |Reward=Evolith with random augment, {{KI}} Naji's linkpearl
--   1. Speak to Helga (A) at (G-5), southeast of Veridical Conflux #06.
--   2. Speak to Naji (A) at (J-5). He gives you {{KI}} Naji's gauger plate.
--      "Naji will appear as if he has Invisible cast on him."
--   3. Return and speak to Helga (A) to complete. You hand over the key item.
--
-- CSIDS DECODED, NOT GUESSED. Helga is 16839226 -> zone 15 idx 570
-- (0x0100F23A), Naji 16839228 -> idx 572 (0x0100F23C). Both carry several
-- quests; csidscan.py against `xi-dat dialog 15` separates them:
--   Helga 270 -> 8003-8009  THE OFFER. 8004 "I grow concerned about the safety
--          of my fellow captain, Naji", 8005 "he had his trusty Soulgauger in
--          hand", closing on 8009 "You must find him, ${name-player}". There is
--          NO ${selection-lines} in the block, so speaking to her starts it.
--   Helga 271 -> 8010/8011  the reminder ("Have you brought news of Naji?").
--   Helga 272 -> 7889 + 8010 + 8024-8031  THE TURN-IN. 7889 is "You hand over
--          ${keyitem-singular: 0[2]}", then 8026 "You've brought his latest
--          reconnaissance data?", 8030 "I want you to work with Naji... Now take
--          this", and 8031 "You may also find this to be of some use to you.
--          Take it as payment for your efforts." -- the two rewards, in order.
--   Helga 273 -> 8029       her post-completion line.
--   Helga 211/241/242/243 -> 7884/7909-7920  these are ROSE ON THE HEATH (the
--          password/linkpearl introduction, "Halt! Who goes there!?"). Not used
--          here.
--   Naji  274 -> 8012/8013  his line before this quest ("Think you could be any
--          more blunderingly obvious?").
--   Naji  275 -> 8014-8023  THE MEETING. 8016 "I wouldn't even be here myself
--          if the damned fiends hadn't got my leg", and 8021 "This
--          ${item-singular: 0[2]} here is the fruit of my ill-fated recon
--          mission. Deliver it to Helga, along with the news that I'm safe and
--          sound." -- this is where the key item is handed to the player.
--   Naji  276 -> 8012       his one-line brush-off.
--   Naji  277-280/295 -> 8032-8055  these are PLAYING PAPARAZZI (the |Next=
--          quest, which consumes the linkpearl this quest awards). Not used here.
--
-- EVERY EVENT HERE FIRES BARE -- NO ITEM PARAMS. 8021 names an item while 7889
-- names a KEY item, which looked like it needed two different params from Lua.
-- It does not: loading both blocks with csidmsg.load() shows each carries its own
-- data[] and reads the ids out of it.
--     Helga data[29] = 1601  (Naji's gauger plate, for 7889)
--     Naji  data[11] = 2480  (Gauger Plate, for 8021)
--     Naji  data[18] = 1602  (Naji's linkpearl, used by Playing Paparazzi)
-- The items and key items are supplied by the events themselves, so passing them
-- from Lua would be redundant and passing the wrong one would be misleading.
--
-- KEY ITEMS: both exist -- NAJIS_GAUGER_PLATE (1601), NAJIS_LINKPEARL (1602).
-- ITEM: Evolith is id 2783 (`item_basic` name `evolith`), which had no enum name
-- and was added as EVOLITH after checking the id was unused.
--
-- ON THE "RANDOM AUGMENT": bg-wiki says the Evolith comes with a random augment
-- but does not publish which pool it draws from, and evolith augments are not in
-- augments.sql in a form this quest could select from. The Evolith is therefore
-- granted unaugmented rather than with an invented augment.
--
-- PREREQUISITE NOTE: bg-wiki's |Previous= is The Soul of the Matter, which runs
-- on the Soulgauger SGR-1 capture system (equip the gauger, photograph an NM at
-- range and frontal angle, trade the plate for appraisal). That system is not
-- built, so The Soul of the Matter is not implemented. The gate below is correct
-- per bg-wiki; that quest still needs building before this one is reachable in a
-- fresh playthrough.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SECRET_AGENT_MAN)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_KONSCHTAT,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_SOUL_OF_THE_MATTER)
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Helga'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(270)
                end,
            },

            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(274)
                end,
            },

            onEventFinish =
            {
                [270] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted, Naji not yet found.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(275)
                end,
            },

            ['Helga'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(271)
                end,
            },

            onEventFinish =
            {
                [275] = function(player, csid, option, npc)
                    -- 8021: he hands over his recon data for delivery to Helga.
                    npcUtil.giveKeyItem(player, xi.ki.NAJIS_GAUGER_PLATE)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- Found him: carry the plate back to Helga.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Helga'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(272)
                end,
            },

            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(276)
                end,
            },

            onEventFinish =
            {
                [272] = function(player, csid, option, npc)
                    -- 7889: the plate changes hands here.
                    player:delKeyItem(xi.ki.NAJIS_GAUGER_PLATE)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)

                        -- 8030 "Now take this" is the linkpearl that Playing
                        -- Paparazzi consumes; 8031 "take it as payment" is the
                        -- Evolith.
                        npcUtil.giveKeyItem(player, xi.ki.NAJIS_LINKPEARL)
                        npcUtil.giveItem(player, xi.item.EVOLITH)
                    end
                end,
            },
        },
    },

    -- Completed: 8029, her closing thought about Naji.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Helga'] = quest:event(273):replaceDefault(),
        },
    },
}

return quest
