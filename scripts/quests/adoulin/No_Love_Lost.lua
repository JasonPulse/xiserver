-----------------------------------
-- No Love Lost
-----------------------------------
-- Log ID: 9, Quest ID: 61
-- Peppe-Aleppe : Kamihr Drifts, Frontier Station, entity 17871211
-- !addquest 9 61
-----------------------------------
-- Retail (bg-wiki "No Love Lost").
-- |Start=Peppe-Aleppe, Kamihr Drifts  |Fame=Adoulin  |Item Reqs=Ruszor Hide
-- |Reward=Algor resilience
-- |Description=Orsa-Porsa claims that Peppe-Aleppe was shipped off to Kamihr Drifts
--   for making unwanted advances on a young woman. Bring Peppe-Aleppe one ruszor
--   hide so he can invent something fabulous to win Amchuchu's favor.
--   1. Peppe-Aleppe is at the Frontier Station in Kamihr Drifts. Talk to him once
--      to flag the quest.
--   2. He asks for a Ruszor Hide. Trade him one to complete the quest and for your
--      reward. "Slobbering Ruszor can be found at Kamihr Drifts (J-7)."
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Peppe-Aleppe is 17871211 -> zone 267 idx 363 (0x0110B16B). `xi-dat events 267`
-- gives him 20, 22, 40, 41, 42, 43. The dumped dialog file labelled zone N holds
-- zone N-1's text for the Adoulin FIELD zones, so Kamihr's text is in the file
-- labelled 268. Read against 268:
--   20 -> 7749/7750  his pre-quest complaining ("It's f-freezing-weezing out here!")
--   22 -> 7753-7756  his chatter while the quest is active: 7754 "ice walls blocking
--         our progress", 7755 "my geomancer friend Traiffeaux can crush them".
--   41 -> 7833-7835  THE ASK. 7833 "Orsa-Porsa wanted you to get one
--         ${item-singular: 1[2]}. I have a suspicion he's more interested in his
--         surveys than actually helping-welping me out...", then 7834 "I'm no
--         inventaru! Maybe I could make some kind of shovel..." No
--         ${selection-lines}, so speaking to him flags it -- which is exactly
--         bg-wiki's "Talk to him once to flag the quest."
--   43 -> 7865/7866  THE TURN-IN. "Did you see the way Orsa-Porsa danced-wanced out
--         of here? We gave him a new lease on life!" / 7866 "if the oil makes him
--         happy, then that's great!"
--
-- WHICH CSID IS THE TURN-IN, SETTLED BY BLOCK SIZE. This quest was twice built
-- wrongly before because 41 and 43 both read as plausible and 40/42 resolved to no
-- text at all. The entry offsets settle it -- csidmsg.load() gives
--     20: 585 (33 bytes)   22: 618 (76 bytes)   40: 694 (1 byte)
--     41: 696 (56 bytes)   42: 695 (1 byte)     43: 752 (154 bytes)
-- so 40 and 42 are single-byte stubs with no program at all, and 43 is by far the
-- largest block -- the reward cutscene. 7865/7866 are its closing lines, not a
-- separate post-completion event, which is why there is no COMPLETED section below.
--
-- ITEM: Ruszor Hide is the existing RUSZOR_HIDE (2755). Note 2755 is ALSO key item
-- id 2755 (Cheer lynx); 7833's placeholder is ${item-singular}, so it is the item.
-- Checked by id in both enums, not by name.
-- The hide is param 1, which is where 7833 reads it from.
-- KEY ITEM: Algor resilience is the existing ALGOR_RESILIENCE (2467).
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.NO_LOVE_LOST)

quest.reward =
{
    keyItem  = xi.ki.ALGOR_RESILIENCE,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no fame level, so availability is the only gate.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.KAMIHR_DRIFTS] =
        {
            ['Peppe-Aleppe'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(41, { [1] = xi.item.RUSZOR_HIDE })
                end,
            },

            onEventFinish =
            {
                [41] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Accepted: bring him the hide.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.KAMIHR_DRIFTS] =
        {
            ['Peppe-Aleppe'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.RUSZOR_HIDE) then
                        return quest:progressEvent(43, { [1] = xi.item.RUSZOR_HIDE })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(22)
                end,
            },

            onEventFinish =
            {
                [43] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:complete(player)
                end,
            },
        },
    },

    -- Completed: 7749/7750, back to complaining about the cold.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.KAMIHR_DRIFTS] =
        {
            ['Peppe-Aleppe'] = quest:event(20):replaceDefault(),
        },
    },
}

return quest
