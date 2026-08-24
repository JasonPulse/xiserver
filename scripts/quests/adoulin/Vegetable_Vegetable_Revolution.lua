-----------------------------------
-- Vegetable Vegetable Revolution
-----------------------------------
-- Log ID: 9, Quest ID: 108
-- Amchuchus_Laboratory : Western Adoulin (J-10), entity 17826028
-- qm (Sih Gates K-8)   : Sih Gates, entity 17875322
-- Cid                  : Metalworks (H-8), entity 17748011
-- !addquest 9 108
-----------------------------------
-- Retail (bg-wiki "Vegetable Vegetable Revolution").
-- |Start=Door: Amuchuchu's Laboratory, Western Adoulin (J-10)
-- |Fame=Adoulin |FLevel=1 |Repeatable=No |Next=Vegetable Vegetable Evolution
-- |Title=Vegetable Revolutionary |Reward=12 Rarab Tail, 2000 Bayld
--   1. Click the laboratory door inside the Inventors' Coalition for a cutscene.
--   2. Check the ??? in the small round room at (K-8) in Sih Gates for a cutscene
--      with Midras and the Memo from Midras.
--   3. Speak with Cid in the Metalworks to receive Cid's catalyst.
--   4. Return to the ??? in Sih Gates for the Chunk of milky white minerals.
--   5. Return to the laboratory door for the reward.
--
-- CSIDS DECODED FROM THE CLIENT EVENT PROGRAMS, not guessed. Each id below was
-- confirmed by reading the dialog its byte range references:
--   Western Adoulin 5054 on 17826028 -> 10750-10765, Amchuchu asking you to look
--       in on "Junior", the 10757 accept/decline prompt, and the 10763 re-ask.
--       One csid serves both the offer and the reminder; the program branches
--       internally, which is why no separate reminder id exists.
--   Western Adoulin 5055 on 17826028 -> 10766-10774, "You met with Cid, too!?"
--       through the reward hand-over.
--   Sih Gates 15 on 17875322 -> 7625/7658, Midras handing over the compound list
--       "give it to my old man".
--   Sih Gates 16 on 17875322 -> 7667, "Excellent. This should serve perfectly."
--   Metalworks 979 on 17748011 -> 7383-7404, Cid reading the memo and producing
--       the explosive powder.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.VEGETABLE_VEGETABLE_REVOLUTION)

local sihGatesQm = 17875322

quest.reward =
{
    fameArea   = xi.fameArea.ADOULIN,
    item       = { { xi.item.RARAB_TAIL, 12 } },
    bayld      = 2000,
    title      = xi.title.VEGETABLE_REVOLUTIONARY,
}

quest.sections =
{
    -- Section: offer
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(5054)
                end,
            },

            onEventFinish =
            {
                [5054] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    -- Section: fetch the mineral sample
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Amchuchus_Laboratory'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CHUNK_OF_MILKY_WHITE_MINERALS) then
                        return quest:progressEvent(5055)
                    end

                    return quest:event(5054)
                end,
            },

            onEventFinish =
            {
                [5055] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CHUNK_OF_MILKY_WHITE_MINERALS)
                    quest:complete(player)
                end,
            },
        },

        [xi.zone.SIH_GATES] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= sihGatesQm then
                        return
                    end

                    if player:hasKeyItem(xi.ki.CIDS_CATALYST) then
                        return quest:progressEvent(16)
                    elseif
                        not player:hasKeyItem(xi.ki.MEMO_FROM_MIDRAS) and
                        not player:hasKeyItem(xi.ki.CHUNK_OF_MILKY_WHITE_MINERALS)
                    then
                        return quest:progressEvent(15)
                    end
                end,
            },

            onEventFinish =
            {
                [15] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.MEMO_FROM_MIDRAS)
                end,

                [16] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.CIDS_CATALYST)
                    npcUtil.giveKeyItem(player, xi.ki.CHUNK_OF_MILKY_WHITE_MINERALS)
                end,
            },
        },

        [xi.zone.METALWORKS] =
        {
            ['Cid'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.MEMO_FROM_MIDRAS) then
                        return quest:progressEvent(979)
                    end
                end,
            },

            onEventFinish =
            {
                [979] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.MEMO_FROM_MIDRAS)
                    npcUtil.giveKeyItem(player, xi.ki.CIDS_CATALYST)
                end,
            },
        },
    },
}

return quest
