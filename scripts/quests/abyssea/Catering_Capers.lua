-----------------------------------
-- Catering Capers
-----------------------------------
-- Log ID: 8, Quest ID: 0
-- Regine   : Abyssea - La Theine (E-3), entity 17318612
-- Rugiette : Abyssea - La Theine (H-7), entity 17318635
-- !addquest 8 0
-----------------------------------
-- Retail (bg-wiki "Catering Capers").
-- |Start=Regine (A) (E-3), Abyssea - La Theine  |Repeatable=yes  |Previous= none
-- |Item Reqs=Plateau Chestnut x3  |Reward=360 Cruor
--   1. Talk to Regine (A) at (E-3) near Veridical Conflux #01.
--   2. She gives you 3 Hatchets and requests you log 3 Plateau Chestnuts from
--      the trees in Abyssea - La Theine. You can bring your own Hatchets.
--   3. Turn in the 3 Plateau Chestnuts to Rugiette (A) at (H-7), Conflux #04.
--   "Zoning is not required to repeat this quest."
--
-- CSIDS DECODED, NOT GUESSED. Regine is 17318612 -> zone 132 idx 724
-- (0x010842D4), Rugiette 17318635 -> idx 747 (0x010842EB). Between them
-- `xi-dat events 132` gives five csids, resolved with csidscan.py against
-- `xi-dat dialog 132`:
--   Regine 168 -> 7862-7868 + 7875  THE OFFER. 7863 explains the leg wound,
--          7864 carries the request ("${number: 1} ${item-given-plurality:
--          1[2], 0[2]} must absolutely be delivered to my sister"), and 7865 is
--          the accept prompt: "Help deliver ${item-plural: 0[2]}?
--          ${selection-lines} How could I refuse a friend? / I'm not your
--          friend." -- "How could I refuse a friend." is the FIRST line, so
--          OPTION 0 ACCEPTS. 7866 is the decline. 7868 names the sister:
--          "My sister is called Rugiette." 7875 is the repeat offer.
--   Regine 166 -> 7869  the reminder, which also gives the directions: "That's
--          ${number: 1} ${item...} delivered to my sister, Rugiette. She awaits
--          at the central encampment... to the southeast."
--   Regine 167 -> 7874  her thanks once Rugiette has been paid.
--   Rugiette 169 -> 7871-7873  THE TURN-IN. "Hm? Why, these are the supplies my
--          sister was supposed to fetch..." / "Doubtless Regine is being her
--          usual lazy self and asked a hapless passerby to do her chores."
--   Rugiette 170 -> 7870  her idle line.
--
-- THE PARAM QUESTION IS SETTLED: THIS EVENT TAKES NO ITEM PARAMS AT ALL.
-- 7864/7865 name the chestnut through ${item...: 0[2]} while 7867 names the
-- Hatchet through the same ${item-singular: 0[2]}, which looked contradictory
-- for a single fire. It is not. Loading the entity block with csidmsg.load()
-- shows the block carries its own data[] table and the event reads the ids out
-- of it rather than from startEvent:
--     data[] = [30, 2608, 3, 7869, 7874, 0, 32, 7862, 7863, 7864, 7865,
--               1, 1021, 7867, 7868, 7866, 7875]
--     csid -> entry offsets = { 166: 1, 167: 39, 168: 70 }
-- data[1] = 2608 Plateau Chestnut, data[12] = 1021 Hatchet, data[2] = 3 the
-- count. Both items and the quantity are supplied by the event itself, which is
-- exactly how one csid names two different items. Passing item params from Lua
-- is therefore unnecessary, and passing the wrong one would be misleading, so
-- these events are fired bare.
--
-- ITEMS: Plateau Chestnut is id 2608 (`item_basic` name `plateau_chestnut`),
-- which had no enum name and was added as PLATEAU_CHESTNUT after checking the
-- id was unused. Hatchet is the existing HATCHET (1021).
--
-- CRUOR: bg-wiki |Reward=360 Cruor, paid by Rugiette on the turn-in.
-----------------------------------
local laTheineID = zones[xi.zone.ABYSSEA_LA_THEINE]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CATERING_CAPERS)

local chestnutCount = 3
local hatchetCount  = 3
local cruorReward   = 360

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=. COMPLETED is accepted
    -- because |Repeatable=yes, and 7875 is Regine's re-offer line.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Regine'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(168)
                end,
            },

            onEventFinish =
            {
                [168] = function(player, csid, option, npc)
                    -- 7865's selection order: 0 "How could I refuse a friend.",
                    -- 1 "I'm not your friend."
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CATERING_CAPERS) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.CATERING_CAPERS)
                    else
                        quest:begin(player)
                    end

                    -- 7867: "Please take this -- it should serve to ease the
                    -- burden of harvesting." bg-wiki: "She gives you 3 Hatchets".
                    npcUtil.giveItem(player, { { xi.item.HATCHET, hatchetCount } })
                end,
            },
        },
    },

    -- Accepted: log the chestnuts, then carry them to Rugiette.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Regine'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(166)
                end,
            },

            ['Rugiette'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, { { xi.item.PLATEAU_CHESTNUT, chestnutCount } }) then
                        return quest:progressEvent(169)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(170)
                end,
            },

            onEventFinish =
            {
                [169] = function(player, csid, option, npc)
                    player:confirmTrade()

                    if quest:complete(player) then
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(laTheineID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    -- Completed: Regine thanks you (7874).
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Regine'] = quest:event(167):replaceDefault(),
        },
    },
}

return quest
