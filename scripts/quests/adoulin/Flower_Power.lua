-----------------------------------
-- Flower Power
-----------------------------------
-- Log ID: 9, Quest ID: 34
-- Mano-Amano : Yorcia Weald, entity 17855086
-- !addquest 9 34
-----------------------------------
-- Retail (bg-wiki "Flower Power").
-- |Start=Mano-Amano, Yorcia Weald  |Previous=Dirt Cheap  |Repeatable=Yes
-- |Fame=Seekers of Adoulin  |Reward=500 Experience Points
--   1. Talk to Mano-Amano at the Frontier Station in Yorcia Weald.
--      "You must zone after completing the previous quest before you can
--      activate this quest."
--   2. "Find and defeat three Numbing Blossoms in Yorcia Weald. You obtain the
--      required items automatically. Zoning after obtaining the items won't
--      restart your progress."
--   3. Return to Mano-Amano for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Mano-Amano is 17855086 -> zone 263 idx 622 (0x0110726E). `xi-dat events 263`
-- gives him 50-58; he carries both this quest and Dirt Cheap. The dumped dialog
-- file labelled zone N holds zone N-1's text for the Adoulin zones, so Yorcia's
-- text is in the file labelled 264; the offset is pinned by this repo's own
-- known-correct id (Yorcia_Weald/IDs.lua WAYPOINT_ATTUNED = 7543 resolves in dump
-- 264). Read against 264, csidscan splits his two quests cleanly -- 8326-8337 is
-- Dirt Cheap (the soil samples) and THIS quest is the 8338-8348 block:
--   54 -> 8338-8342  THE OFFER. 8339 "I investigatarued the earth you brought me,
--         and made a startling discovery. These flores--they don't just paralyze
--         people, but they are partly connected with the pollution-wution", and
--         8341 carries the request: "collect ${number: 0} of the blossoms for me,
--         por favor." No ${selection-lines}, so speaking to him starts it.
--   57 -> 8343       the reminder: "Pull up ${number: 0} numbing blossoms and
--         bringy-wing them back to me, comprende?"
--   58 -> 8337/8344  THE TURN-IN. 8344 "You're back so soon--estupendo! These will
--         make excellentaru specimens." plus 8337's reward line.
--   55 -> 8338 + 8345-8347  the repeat offer, behind his findings: 8347 "Findy-wind
--         me ${number: 0} more numbing blossom${choice-plurality: 0}[/s] and I'll
--         give you another reward."
--   56 -> 8338/8348  the short repeat prompt.
--   50 -> 8325       his idle line about the gloomy sky.
--   51/52/53 -> 8326-8337  Dirt Cheap. Not used here.
--
-- THE COUNT OF THREE IS THE EVENT'S OWN. 8341/8343/8347 all render it as
-- ${number: 0}, which looked like a param. csidmsg.load() shows the block carries
-- its own data[] and reads it out of it -- the table holds a literal 3 alongside
-- the message ids -- which is exactly bg-wiki's "three Numbing Blossoms". So the
-- events fire bare and the 3 below is the same figure from the same place.
--
-- COUNTER MESSAGE: 8349 "Numbing blossoms collected: ${number: 0}/${number: 1}."
--
-- "YOU OBTAIN THE REQUIRED ITEMS AUTOMATICALLY" means the kill itself credits
-- progress -- there is no drop to pick up -- which is why this is an onMobDeath
-- tally rather than a trade. bg-wiki also notes zoning does NOT reset it, so the
-- count lives in a quest var rather than a local var.
-- CLAIM: credited to the killer only, matching how the other Adoulin cull quests
-- behave.
--
-- MUST-ZONE: bg-wiki states you have to zone after Dirt Cheap before this becomes
-- available, so the gate is a mustZone check rather than plain completion.
-----------------------------------
local yorciaID = zones[xi.zone.YORCIA_WEALD]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.FLOWER_POWER)

local blossomsNeeded = 3 -- from Mano-Amano's event block data[]

quest.reward =
{
    exp      = 500,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- |Previous=Dirt Cheap, and bg-wiki requires a zone in between. COMPLETED is
    -- accepted because |Repeatable=Yes; 55 is his re-offer.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or
                    status == xi.questStatus.QUEST_COMPLETED) and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.DIRT_CHEAP) and
                not quest:getMustZone(player)
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['Mano-Amano'] =
            {
                onTrigger = function(player, npc)
                    if player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.FLOWER_POWER) then
                        return quest:progressEvent(55)
                    end

                    return quest:progressEvent(54)
                end,
            },

            onEventFinish =
            {
                [54] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Blossoms', 0)
                end,

                [55] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.FLOWER_POWER)
                    quest:setVar(player, 'Blossoms', 0)
                end,
            },
        },
    },

    -- Accepted: pull up three blossoms, then take them back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YORCIA_WEALD] =
        {
            ['Numbing_Blossom'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if player == nil or not optParams.isKiller then
                        return
                    end

                    local picked = quest:getVar(player, 'Blossoms')
                    if picked >= blossomsNeeded then
                        return
                    end

                    picked = picked + 1
                    quest:setVar(player, 'Blossoms', picked)
                    player:messageSpecial(yorciaID.text.NUMBING_BLOSSOMS_COLLECTED, picked, blossomsNeeded)
                end,
            },

            ['Mano-Amano'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Blossoms') >= blossomsNeeded then
                        return quest:progressEvent(58)
                    end

                    return quest:event(57)
                end,
            },

            onEventFinish =
            {
                [58] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Blossoms', 0)
                    end
                end,
            },
        },
    },
}

return quest
