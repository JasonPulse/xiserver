-----------------------------------
-- Open the Floodgates
-----------------------------------
-- Log ID: 9, Quest ID: 100
-- Risen Hackles  : Eastern Adoulin (G-6), entity 17830105
-- Yeggha Dolashi : Rala Waterways (M-6), entity 17834313
-- !addquest 9 100
-----------------------------------
-- Retail (bg-wiki "Open the Floodgates").
-- |Start=Risen Hackles, Eastern Adoulin  |Fame=Adoulin |FLevel=3
--   1. "Speak with Risen Hackles (G-6) to begin the quest."
--   2. "Speak with Yeggha Dolashi, Rala Waterways (M-6) TWICE to ensure you got the
--      proper dialogue about the Peacekeepers' Coalition."
--   3. "Return to Risen Hackles for your reward."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Eastern Adoulin:
--   2550 -> "You heard of the Rala Waterways, located beneath the areas surrounding
--           the castle?" through "Go speak to the soldier located near the holy
--           battlegrounds"                                             THE OFFER
--   2551 -> "Forgot how to get there already? You're looking for a soldier located in
--           the holy battlegrounds area of the Waterways."             the reminder
--   2552 -> "How are you progressing?" / "Everything checks out, then?" / "If you
--           managed to get that far, then you've succeeded in navigating that area
--           without getting lost. Good work."                           the turn-in
--
-- THE TWO CONVERSATIONS ARE COUNTED, because bg-wiki is specific that Yeggha Dolashi
-- must be spoken to TWICE before the dialogue advances to the Peacekeepers' Coalition
-- and the step registers.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.OPEN_THE_FLOODGATES)

local talksNeeded = 2

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
}

local soldierActions =
{
    onTrigger = function(player, npc)
        local talks = quest:getVar(player, 'Talks')

        if talks < talksNeeded then
            quest:setVar(player, 'Talks', talks + 1)
        end
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Risen_Hackles'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2550)
                end,
            },

            onEventFinish =
            {
                [2550] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Talks', 0)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.RALA_WATERWAYS] =
        {
            ['Yeggha_Dolashi'] = soldierActions,
        },

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Risen_Hackles'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Talks') < talksNeeded then
                        return quest:event(2551)
                    end

                    return quest:progressEvent(2552)
                end,
            },

            onEventFinish =
            {
                [2552] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Talks', 0)
                    end
                end,
            },
        },
    },
}

return quest
