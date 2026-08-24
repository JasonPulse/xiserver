-----------------------------------
-- Further Founts
-----------------------------------
-- Log ID: 3, Quest ID: 173
-- Anastase : Ru'Lude Gardens (G-9), entity 17772843
-- !addquest 3 173
-----------------------------------
-- Retail (bg-wiki "Further Founts").
-- |Start=Anastase, Ru'Lude Gardens (G-9)  |Fame=Jeuno
-- |Previous=Middle Lands Investigation
-- |Reward=New Proto-Waypoint Teleportation Destinations
--   1. Speak to Anastase and take on the survey.
--   2. "You must discover 10 more Geomagnetic Founts hidden throughout Vana'diel
--      by using the hints provided upon asking Anastase about his predictions."
--   3. Return to Anastase.
--   "You must zone after completing Middle Lands Investigation before you are able
--    to accept this quest."
--
-- QUEST ID DERIVED BY THE ANCHOR METHOD. The client's Jeuno DMSG table runs
-- ... 148 VW Op. #118 ... 157 Full Speed Ahead!, which our enum holds at 169 and 179.
-- Between those two verified anchors the DMSG lists exactly eight quests and the enum
-- has exactly eight free ids, 171 to 178, so the run maps one to one. This quest is
-- DMSG 151, landing on 173.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Ru'Lude Gardens:
--   10221 -> "Bottest, my friend! It is good to see you again."      the offer
--   10223 -> "I am pleased that you have returned safely." then "You have traveled
--            to the 10 locations I have requested"                 the turn-in
--   10224 -> "Have you gotten used to using our warp technology?"
--                                                   the post-completion line
--   10222 is the recorded-in-advance variant, mirroring 10218.
--
-- THE FOUNT COUNT COMES FROM ANASTASE HIMSELF, not from counting wiki rows: csid
-- 10223 renders "You have traveled to the 10 locations I have requested and recorded
-- the data in the geomagnetic founts there!"
--
-- The tier's zone list and the progress mask live in
-- scripts/globals/proto_waypoint.lua.
-----------------------------------
require('scripts/globals/proto_waypoint')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.FURTHER_FOUNTS)

local tier = 3

local function anastaseTrigger(player, npc)
    if not xi.protoWaypoint.tierComplete(quest, player, tier) then
        -- The offer csid doubles as the progress line, so the running count goes with it.
        return quest:event(10221, xi.protoWaypoint.recorded(quest, player, tier))
    end

    return quest:progressEvent(10223)
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
            [10223] = function(player, csid, option, npc)
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
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.MIDDLE_LANDS_INVESTIGATION) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Anastase'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10221, 0)
                end,
            },

            onEventFinish =
            {
                [10221] = function(player, csid, option, npc)
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
            ['Anastase'] = quest:event(10224):replaceDefault(),
        },
    },
}

return quest
