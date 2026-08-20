-----------------------------------
-- Hop to It
-----------------------------------
-- Log ID: 9, Quest ID: 6
-- Chya_Mindorah : Yahse Hunting Grounds (I-8), entity 17842710
-- qm            : Yahse Hunting Grounds (I-6/7), entity 17842712
-- !addquest 9 6
-----------------------------------
-- Retail (bg-wiki "Hop to It").
-- |Start=Chya Mindorah, Yahse Hunting Grounds - (I-8)  |Repeatable=No
-- |Fame=Adoulin  |FLevel=1  |Reward=2000 Experience Points
--   1. Talk to Chya Mindorah at Bivouac #1 to flag the quest. "She asks you to
--      kill a bothersome chapulli that's been eating crops in the area."
--   2. Head north to the border of I-6/7 to find the ???.
--   3. "Kill Calfcleaving Chapuli until you get the message 'You are suddenly
--      overcome with a sense of foreboding...' (the number of chapuli killed
--      appears to be random)." Before that it reads "You feel something
--      approaching from the shadows."
--   4. Click the ??? to spawn the NM Bothersome Chapuli.
--   5. Killing the NM gives a Chapuli horn. Return to Chya Mindorah.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Chya Mindorah is 17842710 -> zone 260 idx 534 (0x01104216). `xi-dat events 260`
-- gives her 2510-2513. The dumped dialog file labelled zone N holds zone N-1's
-- text for the Adoulin zones, so Yahse's text is in the file labelled 261; the
-- offset is pinned by this repo's own known-correct id
-- (Yahse_Hunting_Grounds/IDs.lua WAYPOINT_ATTUNED = 7619 resolves in dump 261).
-- Read against 261:
--   2510 -> 7520-7524  THE OFFER. 7520 "How about clipping the wings of that
--          cursed chapuli for me?", 7521 "What I need from you is to take out the
--          big one--the head of the whole cloud", and 7523 "It's masterrrfully
--          good at staying out of sight, but attacking its swarm should call it
--          out of hiding" -- which is the kill-the-swarm-first mechanic stated
--          in-game. No ${selection-lines}, so speaking to her starts it.
--   2511 -> 7520/7523  the reminder: thin the swarm to draw the big one out.
--   2512 -> 7525-7528  THE TURN-IN. "You brought it, lock, stock, and barrel!"
--          through to 7528 "this mere trifle will have to suffice."
--   2513 -> 7526       her post-completion line.
--
-- THE ??? IS THE NM'S OWN SPAWN POINT, MATCHED BY POSITION, NOT BY GUESS. The qm
-- 17842712 sits at (25.000, 206.000) and mob_spawn_points puts Bothersome_Chapuli
-- (17842538) at (26.180, 205.247) -- the same spot, which is what identifies this
-- qm as the pop point out of the two qm entities in the zone. It owns no csid of
-- its own, so its two lines are plain messages rather than an event, the same
-- shape the Shellfish gathering points use.
--
-- MESSAGES: 6406 "You are suddenly overcome with a sense of foreboding..." (swarm
-- thinned enough) and 7530 "You feel something approaching from the shadows."
-- (not yet) -- both bg-wiki quotes them verbatim.
--
-- KEY ITEM: Chapuli horn is the existing CHAPULI_HORN (2221).
--
-- THE KILL COUNT IS RANDOM PER RETAIL. bg-wiki says outright that "the number of
-- chapuli killed appears to be random", so a threshold is rolled per playthrough
-- rather than fixed; nothing in the event block carries a count to read instead.
-----------------------------------
local yahseID = zones[xi.zone.YAHSE_HUNTING_GROUNDS]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.HOP_TO_IT)

local nmSpawnPoint = 17842538 -- Bothersome_Chapuli, mob_spawn_points

quest.reward =
{
    exp      = 2000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous=, and |FLevel=1 is the base fame level every
    -- character already has.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Chya_Mindorah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2510)
                end,
            },

            onEventFinish =
            {
                [2510] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Swarm', 0)
                    -- Rolled once per playthrough; bg-wiki: the count is random.
                    quest:setVar(player, 'SwarmNeeded', math.random(3, 6))
                end,
            },
        },
    },

    -- Accepted: thin the swarm, pop the NM, take its horn back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Calfcleaving_Chapuli'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil or not optParams.isKiller then
                        return
                    end

                    local killed = quest:getVar(player, 'Swarm')
                    if killed < quest:getVar(player, 'SwarmNeeded') then
                        quest:setVar(player, 'Swarm', killed + 1)
                    end
                end,
            },

            ['Bothersome_Chapuli'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil or not optParams.isKiller then
                        return
                    end

                    if not player:hasKeyItem(xi.ki.CHAPULI_HORN) then
                        npcUtil.giveKeyItem(player, xi.ki.CHAPULI_HORN)
                    end
                end,
            },

            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CHAPULI_HORN) then
                        return
                    end

                    if quest:getVar(player, 'Swarm') < quest:getVar(player, 'SwarmNeeded') then
                        player:messageSpecial(yahseID.text.APPROACHING_FROM_SHADOWS)
                        return
                    end

                    local nm = GetMobByID(nmSpawnPoint)
                    if nm ~= nil and not nm:isSpawned() then
                        player:messageSpecial(yahseID.text.SENSE_OF_FOREBODING)
                        nm:setSpawn(npc:getXPos(), npc:getYPos(), npc:getZPos())
                        nm:spawn()
                        nm:updateClaim(player)
                    end
                end,
            },

            ['Chya_Mindorah'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CHAPULI_HORN) then
                        return quest:progressEvent(2512)
                    end

                    return quest:event(2511)
                end,
            },

            onEventFinish =
            {
                [2512] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CHAPULI_HORN)

                    if quest:complete(player) then
                        quest:setVar(player, 'Swarm', 0)
                        quest:setVar(player, 'SwarmNeeded', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7526, on to the wider dangers of Ulbuka.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Chya_Mindorah'] = quest:event(2513):replaceDefault(),
        },
    },
}

return quest
