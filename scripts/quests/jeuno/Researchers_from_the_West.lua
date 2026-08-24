-----------------------------------
-- Researchers from the West
-----------------------------------
-- Log ID: 3, Quest ID: 171
-- Anastase : Ru'Lude Gardens (G-9), entity 17772843
-- !addquest 3 171
-----------------------------------
-- Retail (bg-wiki "Researchers from the West").
-- |Start=Anastase, Ru'Lude Gardens (G-9)  |Fame=Jeuno
-- |Previous=None
-- |Reward=Proto-Waypoint Teleportation
--   1. Speak to Anastase and take on the survey.
--   2. "You must discover 4  Geomagnetic Founts hidden throughout Vana'diel
--      by using the hints provided upon asking Anastase about his predictions."
--   3. Return to Anastase.
--   "After discovering each Proto-Waypoint, speak to the NPC standing nearby to
--    activate teleportation." Those NPCs are Jillia in Selbina, Zurko-Bazurko in
--    Mhaura, Quwi Orihbhe in Rabao and Wistful Bison in Norg.
--
-- QUEST ID DERIVED BY THE ANCHOR METHOD. The client's Jeuno DMSG table runs
-- ... 148 VW Op. #118 ... 157 Full Speed Ahead!, which our enum holds at 169 and 179.
-- Between those two verified anchors the DMSG lists exactly eight quests and the enum
-- has exactly eight free ids, 171 to 178, so the run maps one to one. This quest is
-- DMSG 149, landing on 171.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Ru'Lude Gardens:
--   10213 -> "Hmm...something's not right here." / "Who's this then? An adventurer,
--            I gather?"                                          THE OFFER
--   10215 -> "Hail, and good tidings. May I please take a look at your prototype
--            attuner?" then the four-location praise and the reward  the turn-in
--   10216 -> "My efforts now are focused on obtaining information about any more
--            geomagnetic founts that may exist."         the post-completion line
--
-- THE FOUNT COUNT COMES FROM ANASTASE HIMSELF, not from counting wiki rows: csid
-- 10215 renders "You have traveled to the 4 locations I have requested and recorded
-- the data in the geomagnetic founts there!"
--
-- The tier's zone list and the progress mask live in
-- scripts/globals/proto_waypoint.lua.
-----------------------------------
require('scripts/globals/proto_waypoint')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.RESEARCHERS_FROM_THE_WEST)

local tier = 1

local function anastaseTrigger(player, npc)
    if not xi.protoWaypoint.tierComplete(quest, player, tier) then
        -- The offer csid doubles as the progress line, so the running count goes with it.
        return quest:event(10213, xi.protoWaypoint.recorded(quest, player, tier))
    end

    return quest:progressEvent(10215)
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
            [10215] = function(player, csid, option, npc)
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
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Anastase'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10213, 0)
                end,
            },

            onEventFinish =
            {
                [10213] = function(player, csid, option, npc)
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
            ['Anastase'] = quest:event(10216):replaceDefault(),
        },
    },
}

return quest
