-----------------------------------
-- Aqua Pura
-----------------------------------
-- Log ID: 8, Quest ID: 35
-- High_Bear  : Abyssea - Vunkerl (I-9), entity 17666740
-- Watergrass : Abyssea - Vunkerl, entities 17666742 / 17666743 / 17666744
-- !addquest 8 35
-----------------------------------
-- Retail (bg-wiki "Aqua Pura").
-- |Start=High Bear (A) (I-9), Abyssea - Vunkerl  |Next=Aqua Puraga
-- |Reward=400 Cruor
--   1. Speak to High Bear (A) at (I-9), near Conflux #00.
--   2. Examine the Watergrass at (E-5), (G-10) and the north-east corner of
--      (F-13). "These can be done in any order."
--   3. Return to High Bear for your reward.
--
-- CSIDS DECODED, NOT GUESSED. High Bear is 17666740 -> zone 217 idx 692
-- (0x010D92B4). `xi-dat events 217` gives him 1023-1026 and 1029-1033;
-- csidscan.py against `xi-dat dialog 217` splits the two quests he owns:
--   1023 -> 8146-8168  THE OFFER. 8147 is a three-way conversational menu
--          ("Why, only all the time! / Er...not really. / Have we met before?")
--          -- every branch converges on the request, so there is no decline to
--          test. 8162 "I need you to procure a few choice samples of the plants
--          in this area", 8166 "There are three ponds here in the inlet... I
--          would have you procure one sample of flora from the banks of each",
--          8167 "on your map, that would be here, here, and...yes, right about
--          here."
--   1024 -> 8169/8170  the reminder, the request without the preamble.
--   1025 -> 8173-8175  THE TURN-IN. "You've brought me the samples I
--          requested. Wonderful!" / "Take this as a small token of my thanks."
--   1026 -> 8176/8177  his post-completion lines (analysis under way).
--   1029/1031 -> 8178-8225  these are AQUA PURAGA (the |Next= quest): 8187
--          "Return to the three sites that you visited, and take note of any
--          curious qualities in the plant life there", and 8199's nine-option
--          findings menu. Deliberately not used here.
--   Watergrass 1034 (17666742), 1036 (17666743), 1038 (17666744) -> 8171
--          "You pluck a handful of watergrass from the ground." -- the
--          collection. Their OTHER csids, 1035/1037/1039 -> 8189-8197, are the
--          nine Aqua Puraga observation lines, not this quest.
--
-- THE MAP MARKERS ARE SUPPLIED BY THE EVENT, NOT BY LUA. 8167 places three
-- markers, and loading the block with csidmsg.load() shows they come out of the
-- block's own data[]:
--     data[26] = 217 (the zone) followed by 4294790928, 4294620312, 4294664063,
--     4294279946, 3, 4294485105, 582936  -- the packed coordinates and the
--     count 3.
-- So csid 1023 is fired bare; passing positions from Lua would be redundant.
--
-- PROGRESS is a three-bit mask in the quest var 'Samples', one bit per pond, so
-- the three can be gathered in any order and none can be counted twice.
-----------------------------------
local vunkerlID = zones[xi.zone.ABYSSEA_VUNKERL]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AQUA_PURA)

local cruorReward = 400

-- Watergrass entity -> bit. (E-5), (G-10), (F-13) in npc_list order.
local watergrassBit =
{
    [17666742] = 0,
    [17666743] = 1,
    [17666744] = 2,
}

local allSamples = 0x07 -- three bits

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['High_Bear'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1023)
                end,
            },

            onEventFinish =
            {
                [1023] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Samples', 0)
                end,
            },
        },
    },

    -- Accepted: pluck watergrass at the three ponds, then report back.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Watergrass'] =
            {
                onTrigger = function(player, npc)
                    local bit1 = watergrassBit[npc:getID()]
                    if bit1 == nil then
                        return
                    end

                    local mask = quest:getVar(player, 'Samples')
                    if bit.band(mask, bit.lshift(1, bit1)) == 0 then
                        quest:setVar(player, 'Samples', bit.bor(mask, bit.lshift(1, bit1)))
                    end

                    -- 8171 is the same line on all three, and it is theirs to
                    -- show whether or not this pond was already sampled.
                    return quest:event(1034 + bit1 * 2)
                end,
            },

            ['High_Bear'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Samples') == allSamples then
                        return quest:progressEvent(1025)
                    end

                    return quest:event(1024)
                end,
            },

            onEventFinish =
            {
                [1025] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Samples', 0)
                        player:addCurrency('cruor', cruorReward)
                        player:messageSpecial(vunkerlID.text.CRUOR_OBTAINED, cruorReward, player:getCurrency('cruor'))
                    end
                end,
            },
        },
    },

    -- Completed: his analysis lines (8176/8177).
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['High_Bear'] = quest:event(1026):replaceDefault(),
        },
    },
}

return quest
