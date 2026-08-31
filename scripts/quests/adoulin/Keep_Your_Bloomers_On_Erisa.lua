-----------------------------------
-- Keep Your Bloomers On, Erisa
-----------------------------------
-- Log ID: 9, Quest ID: 71
-- Door_Research_Chamber : Eastern Adoulin (J-8), entity 17830077
-- Alluring_Plant        : Rala Waterways (F-10), entity 17834272
-- !addquest 9 71
-----------------------------------
-- Retail (bg-wiki "Keep Your Bloomers On, Erisa").
-- |Start=Door: Research Chamber, Eastern Adoulin (J-8)  |Fame=Adoulin  |FLevel=1
-- |Quest Reqs=Yahse Humus  |Reward=1,000 Bayld
--   1. Click the Door: Research Chamber in Eastern Adoulin (J-8).
--   2. Trade Yahse Humus to it.
--   3. Click the northern Alluring Plant at (F-10) in Rala Waterways for the seed.
--   4. Return to the door.
--
-- WHICH PLANT, by elimination rather than by coordinate. All three share message
-- 7930, "leaves are <bulky/thin/bulky> and its fruit is covered with a <hard/hard/
-- soft> shell", selected by one parameter, and Kyff names the right pairing at
-- 10070: bulky leaves, hard shell. That is index 0. The two small plant programs
-- carry their index in data[] between the constants 30 and 7932: 17834270 holds 1
-- (thin, hard) and 17834271 holds 2 (bulky, soft). Both wrong, so 17834272 is it.
-- Its data[] opening 0, 200 where the others open 200, 0 agrees.
--
-- Csids on holder 17830076; ids from dialog-table-257.xml, whose yml is shifted:
--   5024 -> 10024-10045  offer; 10041 asks for the humus
--   5025 -> 10046        reminder
--   5026 -> 10047-10074  trade scene; 10066 names Rala, 10070 names the plant
--   5027 -> 10075-10077  nudge
--   5028 -> 10078-10093  turn-in
--
-- The plant fires its own csid 323, which renders 7930 then asks 7931.
-- Yahse Humus is item_basic clump_of_yahse_humus, 3958.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.KEEP_YOUR_BLOOMERS_ON_ERISA)

local researchChamberDoor = 17830077
local alluringPlant       = 17834272

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 1000,
}

quest.sections =
{
    -- Section: Erisa's fruit will not set and she needs fertiliser.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Door_Research_Chamber'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= researchChamberDoor then
                        return
                    end

                    return quest:progressEvent(5024)
                end,
            },

            onEventFinish =
            {
                [5024] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    -- Section: the humus, then the plant Kyff described.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Door_Research_Chamber'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        npc:getID() ~= researchChamberDoor or
                        quest:getVar(player, 'Prog') ~= 0 or
                        not npcUtil.tradeHasExactly(trade, xi.item.CLUMP_OF_YAHSE_HUMUS)
                    then
                        return
                    end

                    return quest:progressEvent(5026)
                end,

                onTrigger = function(player, npc)
                    if npc:getID() ~= researchChamberDoor then
                        return
                    end

                    local prog = quest:getVar(player, 'Prog')

                    if prog == 0 then
                        return quest:event(5025)
                    elseif prog == 1 then
                        return quest:event(5027)
                    end

                    return quest:progressEvent(5028)
                end,
            },

            onEventFinish =
            {
                [5026] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:setVar(player, 'Prog', 1)
                end,

                [5028] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.TINY_SEED)

                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                    end
                end,
            },
        },

        [xi.zone.RALA_WATERWAYS] =
        {
            ['Alluring_Plant'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= alluringPlant or
                        quest:getVar(player, 'Prog') ~= 1
                    then
                        return
                    end

                    return quest:progressEvent(323)
                end,
            },

            onEventFinish =
            {
                [323] = function(player, csid, option, npc)
                    if npcUtil.giveKeyItem(player, xi.ki.TINY_SEED) then
                        quest:setVar(player, 'Prog', 2)
                    end
                end,
            },
        },
    },
}

return quest
