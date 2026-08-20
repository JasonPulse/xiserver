-----------------------------------
-- Mithran Delicacies
-----------------------------------
-- Log ID: 4, Quest ID: 97
-- Anguenet  : Carpenters' Landing (J-10), entity 16785772
-- Lourdaude : Carpenters' Landing (J-10), entity 16785773, stands beside him
-----------------------------------
-- Retail (bg-wiki "Mithran Delicacies"). |Fame=Other |Repeatable=Yes
-- |Quest Reqs=On the Chains of Promathia Mission Head Wind
-- |Item Reqs=[[Muddy Siredon]]  |Reward=[[Blackened Siredon]]
--   1. Speak to Anguenet at (J-10) and select the 4th option (Newtpool) to begin.
--   2. Fish up (or buy) a Muddy Siredon.
--   3. Trade the Muddy Siredon to Lourdaude; he then "asks" for 100 gil.
--   4. Trade him 100 gil and he gives you the Blackened Siredon.
--
-- THE PREVIOUS VERSION COULD NEVER FIRE. It hung everything on csid 100, and
-- `xi-dat csid 2 100` reports "csid 100 not found in zone 2" -- there is no such
-- event in Carpenters' Landing. It also had no Anguenet step at all, demanded the
-- siredon AND the gil in a SINGLE trade (retail is two separate trades), passed
-- `gil = 100` as a named key inside the item list where npcUtil.tradeHas only
-- reads the nested `{ 'gil', n }` form, and gated its one section on
-- `status == QUEST_AVAILABLE` despite bg-wiki |Repeatable=Yes.
--
-- CSIDs DECODED, NOT GUESSED. Lourdaude is 16785773; (16785773-16777216) = 8557,
-- 8557//4096 = 2 rem 365 -> Carpenters' Landing, 0x0100216D. `xi-dat events 2`
-- gives him exactly five: 26, 24, 22, 25, 27. Resolved with csidscan against
-- `xi-dat dialog 2`:
--   22 -> 7437  "<Sniff...sniff...> ${number: 2}...gil..."  THE ASK, 16 bytes.
--         Fired when the siredon is traded. The ${number: 2} slot is why param 2
--         is the gil cost.
--   24 -> 7437  the same line, 8 bytes -- the reminder while he waits for the gil.
--   25 -> 7438  "...Done..." plus messages 120/200/201, 70 bytes.  THE PAYOUT.
--   26 -> 7439  "..."  his idle line when you are not mid-trade.
--   27 -> a 1-byte stub on Lourdaude; the real 1157-byte program sits on the
--         `qm` holder 16785771, with a second 1-byte stub on ANGUENET
--         (16785772). That shared ownership is the giveaway: 27 is Anguenet's
--         route explanation, and it name-checks Lourdaude, which is why both
--         carry stubs. Its dialog is 7419-7424:
--           7419 "Hear an explanation of the routes? ${selection-lines}
--                 That won't be necessary. / The main canal. / The Emfea
--                 Waterway. / Newtpool."      <- option 3 is bg-wiki's "4th option"
--           7420 "...Our route takes us through Newtpool, which as the name
--                 suggests, is literally squirming with newts."
--           7423 "Ah yes--if you happen to catch yourself a brownish newt, a
--                 ${item-singular: 1[2]}, hand it over to my vertically
--                 challenged partner over there."   <- the flag, param 1 = siredon
--           7424 "He is a man of few words, but I can assure you his delicious
--                 charred newts reflect his unwavering devotion..."
--
-- REWARD ITEM: bg-wiki says "Blackened Siredon"; this repo's enum spells the same
-- item BLACKENED_MUDDY_SIREDON (5266). Checked by id, not by name -- there is no
-- separate BLACKENED_SIREDON entry, and adding one would duplicate 5266.
--
-- FAME: bg-wiki's header is |Fame=Other with no amount. `Other` has no mapped
-- fame area (fame_area.lua mirrors addFame() and has no such region), so the
-- previous fameArea = WINDURST was paying an unrelated nation. No fame is granted
-- rather than granting it to the wrong one.
-----------------------------------
local landingID = zones[xi.zone.CARPENTERS_LANDING]

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MITHRAN_DELICACIES)

local siredonCost = 100

quest.reward =
{
    item = xi.item.BLACKENED_MUDDY_SIREDON,
}

quest.sections =
{
    -- Anguenet's route talk. Choosing Newtpool (option 3) flags the quest.
    -- COMPLETED is accepted too because bg-wiki marks this Repeatable=Yes.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.CARPENTERS_LANDING] =
        {
            ['Anguenet'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(27, { [1] = xi.item.MUDDY_SIREDON })
                end,
            },

            ['Lourdaude'] = quest:event(26),

            onEventFinish =
            {
                [27] = function(player, csid, option, npc)
                    -- 7419's selection order: 0 "That won't be necessary.",
                    -- 1 "The main canal.", 2 "The Emfea Waterway.", 3 "Newtpool."
                    if option ~= 3 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MITHRAN_DELICACIES) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MITHRAN_DELICACIES)
                    else
                        quest:begin(player)
                    end

                    quest:setVar(player, 'Prog', 0)
                end,
            },
        },
    },

    -- Trade the siredon; Lourdaude sniffs it and asks for the gil.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 0
        end,

        [xi.zone.CARPENTERS_LANDING] =
        {
            ['Lourdaude'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.MUDDY_SIREDON) then
                        return quest:progressEvent(22, { [2] = siredonCost })
                    end
                end,

                onTrigger = quest:event(26),
            },

            onEventFinish =
            {
                [22] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    -- He has the newt and wants his 100 gil. 24 is the same line as a reminder.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Prog == 1
        end,

        [xi.zone.CARPENTERS_LANDING] =
        {
            ['Lourdaude'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { 'gil', siredonCost } }) then
                        return quest:progressEvent(25, { [2] = siredonCost })
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(24, { [2] = siredonCost })
                end,
            },

            onEventFinish =
            {
                [25] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(landingID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.BLACKENED_MUDDY_SIREDON)
                        return
                    end

                    player:confirmTrade()

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },
    },
}

return quest
