-----------------------------------
-- The Weatherspoon Inquisition
-----------------------------------
-- Log ID: 9, Quest ID: 136
-- Occultist_Footprints : Yorcia Weald (J-6),   entity 17855033
-- Ergon_Locus          : Sih Gates (K-7),      entity 17875329  Lake of Light
-- Ergon_Locus          : Moh Gates (K-6/7),    entity 17879417  Sweltering Spring
-- Ergon_Locus          : Dho Gates (F/G-12),   entity 17891705  Saliferous Spring
-- Hiding_Place         : Cirdas Caverns (K-7), entity 17883980
-- !addquest 9 136
-----------------------------------
-- Retail (bg-wiki "The Weatherspoon Inquisition").
-- |Start=Nashu, Eastern Adoulin  |Fame=Seekers of Adoulin
-- |Previous=The Good, the Bad, the Clement  |Next=The Weatherspoon War
-- |Reward=500 EXP, 1,000 Bayld
--   1. Zone into Western Adoulin from Ceizak Battlegrounds.
--   2. Check the Occultist Footprints at (J-6) in Yorcia Weald for the pouch.
--   3. Visit the three named Ergon Loci in any order.
--   4. Zone into Cirdas Caverns.
--   5. Check the Hiding Place at the SE corner of (K-7) for the reward.
--
-- WHICH LOCUS, decoded rather than picked by coordinate. Each gate zone holds two to
-- four identical Ergon_Locus entities and bg-wiki names the right one only. The
-- client names them through one Multiple Choice parameter over two shared messages:
--   list A (Sih 7518, Moh 7521, Dho 7514)  ... Lake of Light 13, Sweltering Spring
--          14, Prominence of the Flame 15
--   list B (Sih 7519, Moh 7522, Dho 7515)  ... Prominence of the Ripple 8,
--          Saliferous Spring 9, Loch of Flux 10 ...
-- Each locus program carries the zone's slot-to-name pairing in data[], the same base
-- sequence with its own slot hoisted to the front: Sih 0,12,1,13; Moh 0,14,1,15;
-- Dho 0,24,1,25. Slots run in entity order from the lowest id.
-- Dho's 24 and 25 are past the end of list A, and subtracting 16 lands on list B
-- entries 8 and 9, the second of which is Saliferous Spring. That only comes out
-- right if the two lists are one 16-strided space, which is what proves the read.
--
-- Csids:
--   181 -> 9604-9609  the opening, Western Adoulin holder 17825990; 9609 names J-6
--   114 -> 8154-8190  the footprints; 8187 hands over the pouch, 8189 names the loci
--   32  -> the arrival, Cirdas holder 17883969
--   33  -> 7922-7981  the Hiding Place; 7979 is the payout
--
-- SOFT SPOT: 7918 and 7919 fall inside csids 27 and 28, which
-- Velkkovert_Operations.lua owns from a live probe. 32 is the only unclaimed id
-- between them and the Hiding Place scene, so re-probe 32 first if step 4 misfires.
--
-- The loci handlers return nothing: these entities are shared with the ordinary
-- survey and the Scouts assignments, so a quest must not shadow them.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_WEATHERSPOON_INQUISITION)

local occultistFootprints = 17855033
local hidingPlace         = 17883980

-- Zone to the one locus in it that this quest wants.
local waterLoci =
{
    [xi.zone.SIH_GATES] = { entity = 17875329, bit = 0 },
    [xi.zone.MOH_GATES] = { entity = 17879417, bit = 1 },
    [xi.zone.DHO_GATES] = { entity = 17891705, bit = 2 },
}

local allWater = 7

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
    exp      = 500,
}

local accepted =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,

    [xi.zone.YORCIA_WEALD] =
    {
        ['Occultist_Footprints'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= occultistFootprints or
                    quest:getVar(player, 'Prog') ~= 0
                then
                    return
                end

                return quest:progressEvent(114)
            end,
        },

        onEventFinish =
        {
            [114] = function(player, csid, option, npc)
                if npcUtil.giveKeyItem(player, xi.ki.STURDY_HIDE_POUCH) then
                    quest:setVar(player, 'Prog', 1)
                end
            end,
        },
    },

    [xi.zone.CIRDAS_CAVERNS] =
    {
        ['Hiding_Place'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= hidingPlace or
                    quest:getVar(player, 'Prog') ~= 3
                then
                    return
                end

                return quest:progressEvent(33)
            end,
        },

        onZoneIn = function(player, prevZone)
            if quest:getVar(player, 'Prog') ~= 2 then
                return -1
            end

            return 32
        end,

        onEventFinish =
        {
            [32] = function(player, csid, option, npc)
                quest:setVar(player, 'Prog', 3)
            end,

            [33] = function(player, csid, option, npc)
                player:delKeyItem(xi.ki.STURDY_HIDE_POUCH)

                if quest:complete(player) then
                    quest:setVar(player, 'Prog', 0)
                    quest:setVar(player, 'Water', 0)
                end
            end,
        },
    },
}

for zoneId, locus in pairs(waterLoci) do
    accepted[zoneId] =
    {
        ['Ergon_Locus'] =
        {
            onTrigger = function(player, npc)
                if
                    npc:getID() ~= locus.entity or
                    quest:getVar(player, 'Prog') ~= 1
                then
                    return
                end

                local water = bit.bor(quest:getVar(player, 'Water'), bit.lshift(1, locus.bit))

                quest:setVar(player, 'Water', water)

                if water == allWater then
                    quest:setVar(player, 'Prog', 2)
                end
            end,
        },
    }
end

quest.sections =
{
    -- Section: walking in from Ceizak to find Araustoix whipping up a mob.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.THE_GOOD_THE_BAD_THE_CLEMENT)
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            -- bg-wiki is specific that this fires walking in from Ceizak, and an
            -- unconditional zone-in cutscene is what broke the CoP 5-3 test once.
            onZoneIn = function(player, prevZone)
                if prevZone ~= xi.zone.CEIZAK_BATTLEGROUNDS then
                    return -1
                end

                return 181
            end,

            onEventFinish =
            {
                [181] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 0)
                    quest:setVar(player, 'Water', 0)
                end,
            },
        },
    },

    accepted,
}

return quest
