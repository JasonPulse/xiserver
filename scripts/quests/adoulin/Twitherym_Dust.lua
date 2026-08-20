-----------------------------------
-- Twitherym Dust
-----------------------------------
-- Log ID: 9, Quest ID: 0
-- Gurren-Murren  : Ceizak Battlegrounds (K-7), entity 17846804
-- Twinkling_Tree : Ceizak Battlegrounds (I-10), entity 17846805
-- !addquest 9 0
-----------------------------------
-- Retail (bg-wiki "Twitherym Dust").
-- |Start=Gurren-Murren, Ceizak Battlegrounds - (K-7)  |Previous=None
-- |Repeatable=No  |Fame=Adoulin  |FLevel=1  |Reward=1000 Experience Points
--   1. Speak to Gurren-Murren (K-7, at the Frontier Station).
--   2. Travel south to the Twinkling Tree at the northern part of (I-10) and
--      obtain a Cupful of dust-laden sap.
--   3. Return to Gurren-Murren to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Gurren-Murren is 17846804 -> zone 261 idx 532 (0x01105214), the Twinkling Tree
-- 17846805 -> idx 533 (0x01105215). `xi-dat events 261` gives Gurren-Murren
-- 2500, 2501, 2503, 2507 and the tree 2504.
--
-- Resolving those against `xi-dat dialog 261` produces nonsense -- shellfish and
-- Belaboring Wasp lines that belong to other quests. The dumped dialog file
-- labelled zone N actually holds zone N-1's text for the Adoulin field zones, so
-- Ceizak's text is in the file labelled 262. That is not a reading of mine; it is
-- pinned by this repo's own pre-existing, known-correct ids:
--     Ceizak_Battlegrounds/IDs.lua  WAYPOINT_ATTUNED = 7599
--     Yahse_Hunting_Grounds/IDs.lua WAYPOINT_ATTUNED = 7619
-- and in the dumps 7599 is the attunement line in the file labelled 262 (Ceizak,
-- zone 261) while 7619 is the attunement line in the file labelled 261 (Yahse,
-- zone 260). Both are +1. Read against file 262, this entity's csids resolve
-- exactly onto bg-wiki's walkthrough:
--   2500 -> 7499-7504  THE OFFER. 7499 "Have you ever seen a twitherym? They're
--          creatarus with exquisite wings made of pure beauty", 7502 "They imbibe
--          the sap from local trees... When they dance around the t[rees]",
--          7503 "Can you find some of this sap and deliver-wiver it to me?", and
--          7504 "The butterflies nest to the south of here, where the most
--          succulentaru trees reside." There is no ${selection-lines} in the
--          block, so speaking to him starts it.
--   2501 -> 7504       the reminder: go south and find the sap.
--   2503 -> 7505-7507  THE TURN-IN. "Stupendous-wendous! The sap you've brought
--          back contains more dust than I could have hoped for!" / 7507 "I
--          presentaru you with a token of my esteem."
--   2507 -> 7506       his post-completion line.
--   Tree 2504 -> 7508  "The sap contains a faintly glimmering dust." -- this is
--          where the key item is obtained. Its data[] is the single entry [7508],
--          so the tree's event needs no params.
--
-- KEY ITEM: Cupful of dust-laden sap is the existing CUPFUL_OF_DUST_LADEN_SAP
-- (2179).
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.TWITHERYM_DUST)

quest.reward =
{
    exp      = 1000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists |Previous=None, and |FLevel=1 is the base fame level every
    -- character already has, so there is no fame gate to apply.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Gurren-Murren'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2500)
                end,
            },

            onEventFinish =
            {
                [2500] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: fetch the sap from the Twinkling Tree, then return.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Twinkling_Tree'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CUPFUL_OF_DUST_LADEN_SAP) then
                        return
                    end

                    return quest:progressEvent(2504)
                end,
            },

            ['Gurren-Murren'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CUPFUL_OF_DUST_LADEN_SAP) then
                        return quest:progressEvent(2503)
                    end

                    return quest:event(2501)
                end,
            },

            onEventFinish =
            {
                [2504] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.CUPFUL_OF_DUST_LADEN_SAP)
                end,

                [2503] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CUPFUL_OF_DUST_LADEN_SAP)
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7506, still enthusing about his research.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.CEIZAK_BATTLEGROUNDS] =
        {
            ['Gurren-Murren'] = quest:event(2507):replaceDefault(),
        },
    },
}

return quest
