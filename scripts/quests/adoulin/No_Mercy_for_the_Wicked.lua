-----------------------------------
-- No Mercy for the Wicked
-----------------------------------
-- Log ID: 9, Quest ID: 128
-- Rigobertine    : Eastern Adoulin (J-8), entity 17830130
-- Oscairn        : Eastern Adoulin,       entity 17830103
-- Ergon_Locus_qm : Yorcia Weald (I-8),    entity 17855057
-- !addquest 9 128
-----------------------------------
-- Retail (bg-wiki "No Mercy for the Wicked").
-- |Start=Rigobertine, Eastern Adoulin  |Fame=Adoulin
-- |Next=Mistress of Ceremonies  |Reward=4,000 EXP, 1,000 Bayld
--   1. Talk to Rigobertine at (J-8) outside the Order of Weatherspoon.
--   2. Approach Oscairn outside the Peacekeepers' Coalition.
--   3. Examine the Ergon Locus ??? in the Numbing Blossoms south of (I-8).
--   4. Return to Oscairn.
--
-- The mission gate is real. bg-wiki flags this as needing the Adoulin finale, and
-- the text agrees: 13579 and 13637 both speak of Hades in the past tense. Gated on
-- bg-wiki's stated minimum, Yggdrasil Beckons, not the maximum it hedges at.
--
-- Ids from the XML dumps; zone 257's yml is shifted. See Thorn_in_the_Side.lua.
--
-- Eastern Adoulin, on Rigobertine's block except 105 which is on Oscairn:
--   89  -> 13568-13613  offer. No accept prompt; 13569/13574/13603 are flavour.
--   93  -> 13614        Oscairn's nudge
--   90  -> 13615-13641  the coalition scene; 13632 is the hook
--   105 -> 13642        nudge back to the coalition
--   91  -> 13644-13666  turn-in, opening on 13643
-- Yorcia Weald:
--   6 -> 8795-8828, holder 17855089. Morimar and Ingrid at the locus.
--
-- Csid 7 and 13667-13702 are Mistress of Ceremonies, not this quest.
-- The locus is Ergon_Locus_qm, distinct from the four plain Ergon_Locus rows.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.NO_MERCY_FOR_THE_WICKED)

local ergonLocusQm = 17855057

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
    exp      = 4000,
}

quest.sections =
{
    -- Section: Ingrid, uncharacteristically, wants company.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedMission(xi.mission.log_id.SOA, xi.mission.id.soa.YGGDRASIL_BECKONS)
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Rigobertine'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(89)
                end,
            },

            onEventFinish =
            {
                [89] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Section: the coalition, the locus, and back again.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Oscairn'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog == 0 then
                        return quest:progressEvent(90)
                    elseif prog == 2 then
                        return quest:progressEvent(91)
                    end

                    return quest:event(105)
                end,
            },

            ['Rigobertine'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(93)
                end,
            },

            onEventFinish =
            {
                [90] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [91] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },

        [xi.zone.YORCIA_WEALD] =
        {
            ['Ergon_Locus_qm'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= ergonLocusQm or
                        quest:getVar(player, 'Prog') ~= 1
                    then
                        return
                    end

                    return quest:progressEvent(6)
                end,
            },

            onEventFinish =
            {
                [6] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,
            },
        },
    },
}

return quest
