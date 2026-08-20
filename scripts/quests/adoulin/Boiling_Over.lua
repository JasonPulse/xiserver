-----------------------------------
-- Boiling Over
-----------------------------------
-- Log ID: 9, Quest ID: 9
-- Leautiere  : Yahse Hunting Grounds (G-7), entity 17842711
-- Magma_Vein : Moh Gates (K-5), entity 17879416
-- !addquest 9 9
-----------------------------------
-- Retail (bg-wiki "Boiling Over").
-- |Start=Leautiere, Yahse Hunting Grounds - (G-7)  |Fame=Adoulin
-- |Reward=2000 Experience Points
--   1. Speak with Leautiere at Bivouac #2 in Yahse Hunting Grounds.
--   2. Examine the Magma Vein at (K-5) in Moh Gates to obtain a
--      Magma survey report. "This area is normally blocked by a Colonization
--      Reive."
--   3. Return to Leautiere for your reward.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Leautiere is 17842711 -> zone 260 idx 535 (0x01104217); the Magma Vein is
-- 17879416 -> zone 269 idx 376 (0x0110D178). `xi-dat events` gives Leautiere
-- 2540, 2541, 2542, 2543 and the vein 2500.
--
-- The dumped dialog file labelled zone N holds zone N-1's text for the Adoulin
-- field zones. That offset is pinned by this repo's own known-correct ids rather
-- than by my reading of the prose: Yahse_Hunting_Grounds/IDs.lua has
-- WAYPOINT_ATTUNED = 7619 and Ceizak_Battlegrounds/IDs.lua has 7599, and in the
-- dumps 7619 is the attunement line in the file labelled 261 (Yahse is zone 260)
-- while 7599 is the attunement line in the file labelled 262 (Ceizak is 261).
-- Read against file 261, Leautiere resolves onto bg-wiki exactly:
--   2540 -> 7532-7536  THE OFFER. 7532 "One distinctive landmark of the Yahse
--          Hunting Grounds is the Moh Gates, a grotto leading to the Morimar
--          Basalt Fields", 7533 "the presence of several large fissures from
--          which magma boils forth", 7535 "I would request that you visit the
--          gates, examine in great detail these fissures and the magma contained
--          within, then report your findings back to me", and 7536 the warning
--          about the fiends inside. No ${selection-lines}, so speaking starts it.
--   2541 -> 7536       the reminder, the warning on its own.
--   2542 -> 7537-7542  THE TURN-IN. "Not even the horrors of the deeps can stop
--          you! Pray tell, what have you discovered?", through the ergon loci
--          explanation, to 7542 "Your efforts deserve appropriate compensation."
--   2543 -> 7540/7541  his post-completion musing on the locus.
--   Vein 2500 -> 7498/7499, read against the file labelled 270 (Moh Gates is zone
--          269): "A strange energy rises forth from the magma." / "You write down
--          your findings." -- this is where the report is obtained. Its data[] is
--          just [7498, 7499], so the event needs no params.
--
-- KEY ITEM: Magma survey report is the existing MAGMA_SURVEY_REPORT (2232).
--
-- NO REIVE GATE. bg-wiki notes the area is "normally blocked by a Colonization
-- Reive" and suggests entering from the Morimar Basalt Fields station instead.
-- That is a routing note about world state, not a quest prerequisite, and the
-- Reive system is not implemented here, so nothing is gated on it.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.BOILING_OVER)

quest.reward =
{
    exp      = 2000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Leautiere'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2540)
                end,
            },

            onEventFinish =
            {
                [2540] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: survey the vein in Moh Gates, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MOH_GATES] =
        {
            ['Magma_Vein'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.MAGMA_SURVEY_REPORT) then
                        return
                    end

                    return quest:progressEvent(2500)
                end,
            },

            onEventFinish =
            {
                [2500] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.MAGMA_SURVEY_REPORT)
                end,
            },
        },

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Leautiere'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.MAGMA_SURVEY_REPORT) then
                        return quest:progressEvent(2542)
                    end

                    return quest:event(2541)
                end,
            },

            onEventFinish =
            {
                [2542] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.MAGMA_SURVEY_REPORT)
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7540/7541, his lingering thoughts on the ergon locus.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Leautiere'] = quest:event(2543):replaceDefault(),
        },
    },
}

return quest
