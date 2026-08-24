-----------------------------------
-- Middle Lands Investigation
-----------------------------------
-- Log ID: 3, Quest ID: 172
-- Anastase : Ru'Lude Gardens (G-9), entity 17772843
-- !addquest 3 172
-----------------------------------
-- Retail (bg-wiki "Middle Lands Investigation").
-- |Start=Anastase, Ru'Lude Gardens (G-9)  |Fame=Jeuno
-- |Previous=Researchers from the West
-- |Reward=New Proto-Waypoint Teleportation Destinations
--   1. Speak to Anastase and take on the survey.
--   2. "You must discover 11 more Geomagnetic Founts hidden throughout Vana'diel
--      by using the hints provided upon asking Anastase about his predictions."
--   3. Return to Anastase.
--   "You must zone after completing the previous quest before you can accept."
--
-- QUEST ID DERIVED BY THE ANCHOR METHOD. The client's Jeuno DMSG table runs
-- ... 148 VW Op. #118 ... 157 Full Speed Ahead!, which our enum holds at 169 and 179.
-- Between those two verified anchors the DMSG lists exactly eight quests and the enum
-- has exactly eight free ids, 171 to 178, so the run maps one to one. This quest is
-- DMSG 150, landing on 172.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Ru'Lude Gardens:
--   10217 -> "Bottest, my friend! It is good to see you again. With what may I
--            assist you today?"                       the service menu, the offer
--   10219 -> "You have traveled to the 11 locations I have requested"  the turn-in
--   10220 -> "Still, I have one concern. My compatriots have yet to return from
--            their dispatch."                          the post-completion line
--   10218 is a variant for a player who recorded the founts BEFORE being asked.
--
-- THE FOUNT COUNT COMES FROM ANASTASE HIMSELF, not from counting wiki rows: csid
-- 10219 renders "You have traveled to the 11 locations I have requested and recorded
-- the data in the geomagnetic founts there!"
--
-- The tier's zone list and the progress mask live in
-- scripts/globals/proto_waypoint.lua.
-----------------------------------
require('scripts/globals/proto_waypoint')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.MIDDLE_LANDS_INVESTIGATION)

local tier = 2

local function anastaseTrigger(player, npc)
    if not xi.protoWaypoint.tierComplete(quest, player, tier) then
        -- The offer csid doubles as the progress line, so the running count goes with it.
        return quest:event(10217, xi.protoWaypoint.recorded(quest, player, tier))
    end

    return quest:progressEvent(10219)
end

local accepted =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,

    [xi.zone.RULUDE_GARDENS] =
    {
        ['Anastase'] = { onTrigger = anastaseTrigger },

        onEventFinish =
        {
            [10219] = function(player, csid, option, npc)
                if quest:complete(player) then
                    quest:setVar(player, 'Founts', 0)
                end
            end,
        },
    },
}

for zoneId, handlers in pairs(xi.protoWaypoint.fountZones(quest, tier)) do
    accepted[zoneId] = handlers
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.RESEARCHERS_FROM_THE_WEST) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Anastase'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10217, 0)
                end,
            },

            onEventFinish =
            {
                [10217] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Founts', 0)
                    npcUtil.giveKeyItem(player, xi.ki.PROTOTYPE_ATTUNER)
                end,
            },
        },
    },

    accepted,

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Anastase'] = quest:event(10220):replaceDefault(),
        },
    },
}

return quest
