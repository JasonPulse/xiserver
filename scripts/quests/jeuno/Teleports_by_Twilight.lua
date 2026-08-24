-----------------------------------
-- Teleports by Twilight
-----------------------------------
-- Log ID: 3, Quest ID: 176
-- Nantoto : Lower Jeuno (H-8), entity 17780982
-- !addquest 3 176
-----------------------------------
-- Retail (bg-wiki "Teleports by Twilight").
-- |Start=Nantoto, Lower Jeuno (H-8)  |Fame=Jeuno  |Repeatable=No
-- |Quest Reqs=Must have 50 unique RoE objectives completed.
-- |Reward=1500 Sparks, 2500 Experience Points, 3 Copper A.M.A.N. Vouchers
--   1. "Talk to Nantoto at H-8 in Lower Jeuno after you have completed 50 unique
--      Records of Eminence quests."
--   2. "She asks you to investigate all six telepoint crystals."
--   3. "Touch all 6 telepoint crystals."
--
-- QUEST ID DERIVED BY THE ANCHOR METHOD, not guessed. The client's Jeuno DMSG table
-- runs ... 148 VW Op. #118 ... 157 Full Speed Ahead!, and our enum has those two at
-- 169 and 179. Between them the DMSG lists exactly eight quests and our enum has
-- exactly eight free ids, 171 through 178, so the run maps one to one and Teleports
-- by Twilight at DMSG 154 lands on 176. Both flanking anchors are quests we already
-- had, which is what makes the run safe to extrapolate across.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Lower Jeuno:
--   20035 -> "That...that's a memorandoll!" / "another adventurer who sully-wullied
--            her hands with Records of Eminence, I see."         her first greeting
--   20036 -> "Your mission, should you choose to remember-wember it, is to
--            investigate the various telepoints scattered throughout Vana'diel." and
--            "...Not the ripest pamama in the bunch, I see. You haven't investigated
--            a single-wingle one!"                    THE BRIEF, and the progress
--            report; the count it scolds you with is a parameter
--   20049 -> "Here. Now get out of my sightaru!"                      the payout
--
-- 20049 is taken by position: it is a bare reward handover, it sits immediately after
-- this quest's brief in her program, and the only other bare handover, 20050, follows
-- Shifty Shades of Prey's brief the same way.
-----------------------------------
require('scripts/globals/nantoto_records')
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.TELEPORTS_BY_TWILIGHT)

local requiredRecords = 50
local crystalCount    = 6

local sparksReward   = 1500
local expReward      = 2500
local voucherReward  = 3

--- Which bit this zone's crystal owns. The shared list is ordered precisely so this
--- index is stable.
local function crystalIndex(zoneId)
    for index, entry in ipairs(xi.nantoto.telepoints) do
        if entry.zone == zoneId then
            return index - 1
        end
    end

    return nil
end

local function touchedAll(player)
    local full = bit.lshift(1, crystalCount) - 1

    return bit.band(quest:getVar(player, 'Crystals'), full) == full
end

--- Touching a crystal. Returns nothing so the telepoint's own script still runs.
local telepointAction =
{
    onTrigger = function(player, npc)
        local index = crystalIndex(player:getZoneID())

        if index ~= nil and npc:getID() == xi.nantoto.telepoints[index + 1].npc then
            quest:setVar(player, 'Crystals',
                bit.bor(quest:getVar(player, 'Crystals'), bit.lshift(1, index)))
        end
    end,
}

--- The same handler is registered in each telepoint's own zone.
local function telepointSections()
    local zones = {}

    for _, entry in ipairs(xi.nantoto.telepoints) do
        zones[entry.zone] = { ['Telepoint'] = telepointAction }
    end

    return zones
end

local accepted =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,

    [xi.zone.LOWER_JEUNO] =
    {
        ['Nantoto'] =
        {
            onTrigger = function(player, npc)
                if not touchedAll(player) then
                    -- 20036 scolds with the count, so it is passed through.
                    local touched = 0

                    for index = 0, crystalCount - 1 do
                        if bit.band(quest:getVar(player, 'Crystals'), bit.lshift(1, index)) ~= 0 then
                            touched = touched + 1
                        end
                    end

                    return quest:event(20036, touched)
                end

                return quest:progressEvent(20049)
            end,
        },

        onEventFinish =
        {
            [20049] = function(player, csid, option, npc)
                if quest:complete(player) then
                    xi.nantoto.payReward(player, sparksReward, expReward, voucherReward)
                end
            end,
        },
    },
}

for zoneId, handlers in pairs(telepointSections()) do
    accepted[zoneId] = handlers
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getNumEminenceCompleted() >= requiredRecords
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Nantoto'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(20036, 0)
                end,
            },

            onEventFinish =
            {
                [20036] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Crystals', 0)
                end,
            },
        },
    },

    accepted,
}

return quest
