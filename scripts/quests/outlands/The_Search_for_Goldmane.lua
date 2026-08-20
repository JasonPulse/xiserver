-----------------------------------
-- The Search for Goldmane
-----------------------------------
-- Log ID: 5, Quest ID: 200
-- Zoriboh    : Rabao (F-6), entity 17788995
-- Quelveuiat : Tavnazian Safehold (I-10), entity 16883765
-- Sanctia    : Riverne - Site A01, entity 16900396
-- Trunk      : Riverne - Site A01, entity 16900395
-- Vladinek   : Metalworks (H-8), entity 17748132
-- Weathered_Boat : Bibiki Bay - Purgonorgo Isle (F-9), entity 16794009
-----------------------------------
-- Retail (bg-wiki "The Search for Goldmane").
-- |Fame=r (Rabao)  |Repeatable=No  |Previous=Chasing Dreams
-- |Quest Reqs=Promathia Mission 2-5  |Reward=Deluxe Carbine, 3,000 gil
--   1. Talk to Zoriboh and obtain the Care Package key item.
--   2. Speak to Quelveuiat in Tavnazian Safehold.
--   3. Go to Riverne - Site A01 and through the portals to the island at I-11;
--      a cutscene plays on reaching it.
--   4. Trade a Copper Key to the Trunk for another cutscene. The key drops from
--      Riverne Vulture in Riverne - Site A01.
--   5. Travel to the Metalworks and talk to Vladinek.
--   6. Go to Bibiki Bay, take the Manaclipper to Purgonorgo Isle, and click the
--      Weathered Boat at F-9. Rohemolipaud spawns.
--   7. Click the Weathered Boat again for a cutscene and the Deluxe Carbine.
--   8. Return to Zoriboh to complete the quest and receive 3,000 gil.
--
-- WHAT WAS THERE BEFORE. A "Simplified for 4-player server" stub: accept at
-- Zoriboh (csid 400) -> zone into Riverne - Site A01 -> return to Zoriboh
-- (csid 401). Both csids are fabricated -- `xi-dat csid 247 400` and `401` both
-- report "not found in zone 247", so the stub could never fire at all. Its one
-- section was also gated on nothing but `status == QUEST_AVAILABLE`, dropping
-- both the Promathia 2-5 requirement and the Chasing Dreams prerequisite, and
-- it never granted the Deluxe Carbine.
--
-- CSIDS DECODED, NOT GUESSED. Every id below was resolved with
-- `xi-dat events/csid/dialog` plus `csidmsg.py`, and identified by the dialog
-- text it actually emits:
--
--   Rabao (247), Zoriboh 17788995 -> 0x010F7043. He owns 119,120,121,122,123,
--   124,127,128,129. 119/121 belong to Chasing Dreams -- that quest already
--   completes on 121 (Chasing_Dreams.lua) -- which is what splits the block:
--     123  msg 10530 "What do you say? ${selection-lines} I'll do it. /
--          I don't have time for babysitting."   THE OFFER. "I'll do it." is
--          the FIRST selection line, so OPTION 0 ACCEPTS. 10532-10533 are the
--          Care Package hand-over ("Oh, and give this to Sanctia when you find
--          her." / "Chelvadurai wanted her to have it for her birthday.").
--     124  msgs 10527/10528 "Sanctia hasn't come back from Tavnazia..." /
--          "She must still be looking for Goldmane" -- the active reminder.
--     128  THE COMPLETION, msgs 10536-10547. The 750-byte program sits on the
--          `qm3` holder 17788994 with 1-byte 0x00 stubs on Zoriboh AND
--          Chelvadurai 17788997 -- exactly the two speakers in that dialog,
--          which is what confirms the id. 10545 is the reward line.
--     129  msg 10548, post-completion flavour.
--
--   Tavnazian Safehold (26), Quelveuiat 16883765 -> 0x0101A035:
--     397  msgs 11152-11154, 11152 "The fiery young damsel is on a quest to
--          find the famous Goldmane!"
--
--   Riverne - Site A01 (30). Both events are shared by every actor in the
--   scene, which is the multi-actor cutscene pattern:
--     40   the island meeting, msgs 7665-7675. Sanctia refuses the package
--          ("I don't need that either.") until 7673 "If you find something
--          around here that belonged to Goldmane, I'll take the package off
--          your hands."  Carried by qm/Trunk/Sanctia/Novice_Moogle.
--     41   msg 7677 "You open the trunk with the key!" -> 7682 "Goldmane is
--          under the protection of the Bastokan navy!"  7676 is the no-key
--          line: "Closely examining the trunk reveals a tiny keyhole. You
--          would need a tiny key to open it..."
--
--   Metalworks (237):
--     887  the Sanctia/Vladinek scene, msgs 10038-10045 ("Yes. My name is
--          Sanctia. I am searching for the bounty hunter Goldmane..."). The
--          1556-byte program sits on the DIRECTOR 17748131, with 1-byte stubs
--          on Vladinek, Sanctia 17748133 and Novice_Moogle 17748134 -- again
--          the speakers, which is what pins it.
--
--   Bibiki Bay (4), Weathered_Boat 16794009 -> 0x01004199, owns 40 then 37:
--     40   the ambush, msgs 7520 "There is a boat washed up on the shore..."
--          and 7521 "You suddenly find yourself fighting for your life!" ->
--          Rohemolipaud spawns (7524 "Only death awaits those who come in
--          search of Goldmane."). 577-byte program.
--     37   the resolution, msgs 7539/7540/7541/7544/7583, reached after 7526
--          "You defeated that horrible man, kupopo!". 4249-byte program, stubs
--          on seven entities. This is where the Deluxe Carbine is given and
--          where the Care Package is finally used -- 7530 "was carrying
--          medicine for your injuries. It was in the package that your father
--          sent".
--
-- SUPPORTING DATA ALREADY EXISTED, none of it invented:
--   Copper Key is item 1665 (`item_basic`), and mob_droplist 2100 already drops
--   it from Riverne_Vulture (mob_groups poolid 3370, zone 30) at UNCOMMON.
--   Rohemolipaud is mob_groups group 46 / pool 3384 in zone 4 with spawntype
--   128. Care Package is key item 631. Only the two item *enum* names were
--   missing (COPPER_KEY, DELUXE_CARBINE); both ids were verified unused before
--   being added.
-----------------------------------
local bibikiBayID = zones[xi.zone.BIBIKI_BAY]
local riverneID   = zones[xi.zone.RIVERNE_SITE_A01]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_SEARCH_FOR_GOLDMANE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SELBINA_RABAO,
    gil      = 3000,
    -- bg-wiki |Title=Rookie Hero Instructor -- nothing granted it.
    title    = xi.title.ROOKIE_HERO_INSTRUCTOR,
}

quest.sections =
{
    -- Zoriboh's offer. bg-wiki gates this on Promathia Mission 2-5 (Ancient
    -- Vows -- the same mapping Spice_Gals.lua uses for that requirement) and on
    -- Chasing Dreams, which is the same NPC and the same story: his Chasing
    -- Dreams event is 121 and this quest's is 123.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.CHASING_DREAMS) and
                player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.ANCIENT_VOWS)
        end,

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(123)
                end,
            },

            onEventFinish =
            {
                [123] = function(player, csid, option, npc)
                    -- 10530's selection order: 0 "I'll do it.",
                    -- 1 "I don't have time for babysitting."
                    if option ~= 0 then
                        return
                    end

                    -- Quest:begin returns nothing (quest.lua:56 is a bare
                    -- addQuest), so the key item cannot be gated on it.
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.CARE_PACKAGE)
                end,
            },
        },
    },

    -- Accepted: go and see Quelveuiat in Tavnazian Safehold.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Quelveuiat'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(397)
                end,
            },

            onEventFinish =
            {
                [397] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- Quelveuiat seen: reach the island in Riverne - Site A01 and meet Sanctia.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.RIVERNE_SITE_A01] =
        {
            ['Sanctia'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(40)
                end,
            },

            onEventFinish =
            {
                [40] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- Sanctia met: she wants something of Goldmane's, so open the Trunk. The
    -- Copper Key drops from Riverne Vulture in this same zone.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 2
        end,

        [xi.zone.RIVERNE_SITE_A01] =
        {
            ['Trunk'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.COPPER_KEY) then
                        return quest:progressEvent(41)
                    end
                end,

                onTrigger = function(player, npc)
                    -- 7676, the retail no-key line.
                    player:messageSpecial(riverneID.text.TRUNK_NEEDS_TINY_KEY)
                end,
            },

            ['Sanctia'] = quest:event(40),

            onEventFinish =
            {
                [41] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 3)
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- The letter names Vladinek of the Bastokan navy; go and see him.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 3
        end,

        [xi.zone.METALWORKS] =
        {
            ['Vladinek'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(887)
                end,
            },

            onEventFinish =
            {
                [887] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 4)
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- Purgonorgo Isle: the boat is an ambush. Rohemolipaud spawns on the
    -- cutscene ending, not before it, so the fight cannot start under the CS.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 4
        end,

        [xi.zone.BIBIKI_BAY] =
        {
            ['Weathered_Boat'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(40)
                end,
            },

            onEventFinish =
            {
                [40] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 5)

                    local nm = SpawnMob(bibikiBayID.mob.ROHEMOLIPAUD)
                    if nm then
                        nm:updateClaim(player)
                    end
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- Rohemolipaud beaten: click the boat again for the Deluxe Carbine.
    -- bg-wiki: "Eventually, he will use Camouflage and the fight will end",
    -- so the boat is re-checkable whether he died or broke off, and it
    -- despawns him rather than leaving him standing.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 5
        end,

        [xi.zone.BIBIKI_BAY] =
        {
            ['Weathered_Boat'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(37)
                end,
            },

            onEventFinish =
            {
                [37] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, xi.item.DELUXE_CARBINE) then
                        DespawnMob(bibikiBayID.mob.ROHEMOLIPAUD)
                        player:delKeyItem(xi.ki.CARE_PACKAGE)
                        quest:setVar(player, 'Prog', 6)
                    end
                end,
            },
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(124),
        },
    },

    -- Back to Zoriboh. 128 plays with Chelvadurai and pays the 3,000 gil.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 6
        end,

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(128)
                end,
            },

            onEventFinish =
            {
                [128] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] = quest:event(129):replaceDefault(),
        },
    },
}

return quest
