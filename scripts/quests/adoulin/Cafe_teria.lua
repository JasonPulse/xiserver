-----------------------------------
-- Cafe...teria
-----------------------------------
-- Log ID: 9, Quest ID: 94
-- Yocile : Eastern Adoulin (G-8), entity 17830014
-- !addquest 9 94
-----------------------------------
-- Retail (bg-wiki "Cafe...teria").
-- |Start=Yocile, Eastern Adoulin (G-8)  |Fame=Adoulin |FLevel=1  |Repeatable=Yes
--   1. "Talk to Yocile in Eastern Adoulin (G-8) near the Statue of the Goddess
--      Waypoint."
--   2. "Trade her 2 Elshimo Coconuts to receive your reward."
--   "This quest is repeatable once per conquest tally."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Eastern Adoulin:
--   3019 -> "Welcome to the Cafe des Larmes! Please, pull up a seat."     her idle
--   3020 -> "I have to apologize for bringing this matter before a customer, but do
--           you have time to help?"                                     THE OFFER
--   3021 -> "Oh, how lovely! You got some for me! Now I'll be able to make those
--           bowls of ulbuconut milk I've been wanting to!"               the turn-in
--   3022 -> "Welcome back! I bet you can guess what I'm going to ask you..."
--                                                                  the repeat offer
--   3023 -> "Remember, I won't have enough until you bring me 2 Elshimo coconuts."
--                                                                      the reminder
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.CAFETERIA)

local coconutsWanted = 2

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

--- "Repeatable once per conquest tally", which is the weekly conquest week.
local function doneThisTally(player)
    return quest:getVar(player, 'Tally') == VanadielUniqueDay() - (VanadielUniqueDay() % 7)
end

local function markTally(player)
    quest:setVar(player, 'Tally', VanadielUniqueDay() - (VanadielUniqueDay() % 7))
end

local coconutTrade =
{
    onTrade = function(player, npc, trade)
        if npcUtil.tradeHasExactly(trade, { { xi.item.ELSHIMO_COCONUT, coconutsWanted } }) then
            return quest:progressEvent(3021)
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 1
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Yocile'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(3020)
                end,

                onTrade = coconutTrade.onTrade,
            },

            onEventFinish =
            {
                [3020] = function(player, csid, option, npc)
                    quest:begin(player)
                end,

                [3021] = function(player, csid, option, npc)
                    quest:begin(player)

                    if quest:complete(player) then
                        player:confirmTrade()
                        markTally(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Yocile'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(3023, coconutsWanted)
                end,

                onTrade = coconutTrade.onTrade,
            },

            onEventFinish =
            {
                [3021] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                        markTally(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Yocile'] =
            {
                onTrigger = function(player, npc)
                    if doneThisTally(player) then
                        return quest:event(3019)
                    end

                    return quest:progressEvent(3022)
                end,

                onTrade = function(player, npc, trade)
                    if
                        not doneThisTally(player) and
                        npcUtil.tradeHasExactly(trade, { { xi.item.ELSHIMO_COCONUT, coconutsWanted } })
                    then
                        return quest:progressEvent(3021)
                    end
                end,
            },

            onEventFinish =
            {
                [3021] = function(player, csid, option, npc)
                    -- A repeat run: the quest is already flagged complete, so the
                    -- reward is paid directly rather than through quest:complete.
                    player:confirmTrade()
                    npcUtil.completeQuest(player, xi.questLog.ADOULIN, xi.quest.id.adoulin.CAFETERIA, quest.reward)
                    markTally(player)
                end,
            },
        },
    },
}

return quest
