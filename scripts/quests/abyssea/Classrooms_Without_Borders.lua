-----------------------------------
-- Classrooms Without Borders
-----------------------------------
-- Log ID: 8, Quest ID: 77
-- Moreno-Toeno : Abyssea - Altepa (K-5), entity 17670743
-- !addquest 8 77
-----------------------------------
-- Retail (bg-wiki "Classrooms Without Borders").
-- |Start=Moreno-Toeno (A) (K-5), Abyssea - Altepa  |Repeatable=Yes
-- |Item Reqs=Manigordo Tusk x3  |Reward=First time completion: 400 Cruor
-- |Previous= (none)
--   1. Speak to Moreno-Toeno (A) at (K-5) near conflux #1 to begin the quest.
--   2. Go to Conflux #7 and defeat Manigordo for three Manigordo Tusks, or
--      acquire them by any other means such as the Auction House.
--   3. Trade the tusks to Moreno-Toeno (A) to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED. Moreno-Toeno is 17670743; (17670743-16777216) =
-- 893527, 893527//4096 = 218 rem 599 -> Abyssea - Altepa, 0x010DA257.
-- `xi-dat events 218` gives him exactly five: 250, 251, 252, 253, 254.
-- Resolved with csidscan.py against `xi-dat dialog 218`:
--   250 -> 7986-7991  THE OFFER. 7986 "How would you like to assistaru me in a
--          simple yet incalculably important task?" through the request itself:
--          7991 "If you could retrieve ${number: 1} ${item-given-plurality:
--          1[2], 0[2]} for me, it would go a long way in helping-welping me
--          achieve educational excellence." The ${number: 1} slot is why the
--          count is param 1.
--   251 -> 7994       the wrong-amount nudge: "${number: 1} ${item...}, I said.
--          Didn't you learn how to take notes in school?"
--   252 -> 7992/7993  THE TURN-IN. "Yes! This is just what I need to conductaru
--          a review session for my students." / "Why, I know! Here, you can
--          have this. If you ever find any more ${item-plural: 0[2]}, don't
--          hesitataru to bring them here."
--   253 -> 7995       the re-offer once completed: "You wouldn't happen to have
--          come across any more ${item-plural: 0[2]}, by any chance?"
--
-- ITEM: Manigordo Tusk is id 2975 (`item_basic`), which had no enum name and was
-- added as MANIGORDO_TUSK after checking the id was unused.
--
-- CRUOR: bg-wiki says 400 on FIRST completion, so the award is inside the
-- quest:complete branch, which only succeeds the first time. Repeats replay 253
-- and the turn-in without re-paying, which is what "First time completion"
-- means. Reported with the zone's CRUOR_OBTAINED text the same way
-- Megadrile_Menace.lua reports its 50.
-----------------------------------
local altepaID = zones[xi.zone.ABYSSEA_ALTEPA]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLASSROOMS_WITHOUT_BORDERS)

local tuskCount   = 3
local cruorReward = 400

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs= for this one, so an
    -- unqualified availability check is correct here. COMPLETED is accepted
    -- because |Repeatable=Yes, and 253 exists precisely to re-offer it.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Moreno-Toeno'] =
            {
                onTrigger = function(player, npc)
                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLASSROOMS_WITHOUT_BORDERS) == xi.questStatus.QUEST_COMPLETED then
                        return quest:progressEvent(253, { [1] = tuskCount })
                    end

                    return quest:progressEvent(250, { [1] = tuskCount })
                end,
            },

            onEventFinish =
            {
                [250] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [253] = function(player, csid, option, npc)
                    player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CLASSROOMS_WITHOUT_BORDERS)
                end,
            },
        },
    },

    -- Accepted: bring him the three tusks.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Moreno-Toeno'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.MANIGORDO_TUSK, tuskCount } }) then
                        return quest:progressEvent(252)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(251, { [1] = tuskCount })
                end,
            },

            onEventFinish =
            {
                [252] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(altepaID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },
}

return quest
