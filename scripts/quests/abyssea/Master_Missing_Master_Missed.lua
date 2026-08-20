-----------------------------------
-- Master Missing, Master Missed
-----------------------------------
-- Log ID: 8, Quest ID: 65
-- Eight_of_Clubs : Abyssea - Grauberg (H-8), entity 17818229
-- Faint_Glister  : Abyssea - Grauberg (J-8), entity 17818230
-- !addquest 8 65
-----------------------------------
-- Retail (bg-wiki "Master Missing, Master Missed").
-- |Start=Eight of Clubs (A) (H-8), Abyssea - Grauberg
-- |Previous=The Mysterious Head Patrol  |Item Reqs=Elegant gemstone
-- |Reward=800 Cruor
--   "You do not need to zone after completing The Mysterious Head Patrol."
--   1. Talk to Eight of Clubs (A) at (H-8), southeast of Conflux #5.
--   2. Interact with the Faint Glister at the northwest corner of (J-8) to
--      obtain an Elegant gemstone. South of Conflux #8.
--   3. Return to Eight of Clubs (A).
--
-- CSIDS DECODED, NOT GUESSED, via csidmsg.load() and find_msg against
-- `xi-dat dialog 254`:
--   Eight_of_Clubs (entries {209:1, 210:30, 211:77, 212:106, 213:161, 214:190,
--   215:449, 222:478, 223:554}):
--     212 -> 7993-7998  THE OFFER. 7994 "Mas-TER iS SLow to reTURn", 7995
--            "mAS-teR sTRuck eaST, bUt haS Not CoMe bAck", 7996 "ShouLD You heAD
--            tHat WAy, CouLD You trY tO FInd MaS-Ter?", and 7997/7998 explain why
--            he cannot go himself: "EiGHt OF cLuBS Is Com-maNDed To stANd viGiL
--            heRe. GooD cArDians oBEy cOM-ManD."
--     213 -> 7999       the reminder, that request condensed into one line.
--     214 -> 8001-8014  THE TURN-IN. 8001 "So maS-teR waS noT TheRe...", 8002
--            "pLeaSE aCCepT thIs foR yOUr trouBleS" -- the reward line -- then
--            8003-8006 are the gemstone recognition that sets up the next quest:
--            "ThaT sTONe iS fAmiLIAr to mE... CouLD iT be... fRoM mY
--            ${keyitem-singular: 0[2]}?"
--     215 -> 8020       his post-completion line: "pleASe LeAVe mE Be foR a
--            WhiLe." His 209/210/211 belong to The_Mysterious_Head_Patrol.lua and
--            222/223 to The_Perils_of_Kororo.lua -- three quests on one Cardian,
--            which is why the entry-offset table is what separates them.
--   Faint_Glister 17818230 owns exactly one csid, 216, and its entire data[]
--   table is [8000] -- "There appears to be something on the ground." So picking
--   the gemstone up is a one-message event, not a cutscene.
--
-- ITEMS, both key items resolved by id: ELEGANT_GEMSTONE (1712) is what the
-- Glister yields, and SILVER_POCKET_WATCH (1711) is the watch from the previous
-- quest that 8004/8006 refer back to. Neither is in item_basic -- a grep there
-- reports them absent, which is the false negative tools/coverage/resolve_item.py
-- was written to prevent.
--
-- CHAIN: The Mysterious Head Patrol (64) -> this (65) -> The Perils of Kororo
-- (66). With this file the Grauberg Cardian chain is complete end to end.
-----------------------------------
local graubergID = zones[xi.zone.ABYSSEA_GRAUBERG]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MASTER_MISSING_MASTER_MISSED)

local cruorReward = 800

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_MYSTERIOUS_HEAD_PATROL)
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Clubs'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(212, { [0] = xi.ki.SILVER_POCKET_WATCH })
                end,
            },

            onEventFinish =
            {
                [212] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: search east -- the Glister at (J-8) holds the gemstone.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Faint_Glister'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.ELEGANT_GEMSTONE) then
                        return
                    end

                    return quest:progressEvent(216)
                end,
            },

            ['Eight_of_Clubs'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.ELEGANT_GEMSTONE) then
                        return quest:progressEvent(214, { [0] = xi.ki.SILVER_POCKET_WATCH })
                    end

                    return quest:event(213)
                end,
            },

            onEventFinish =
            {
                [216] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.ELEGANT_GEMSTONE)
                end,

                [214] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.ELEGANT_GEMSTONE)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(graubergID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_GRAUBERG] =
        {
            ['Eight_of_Clubs'] = quest:event(215):replaceDefault(),
        },
    },
}

return quest
