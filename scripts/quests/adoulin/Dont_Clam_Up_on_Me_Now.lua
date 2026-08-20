-----------------------------------
-- Don't Clam Up on Me Now
-----------------------------------
-- Log ID: 9, Quest ID: 5
-- Oblor     : Yahse Hunting Grounds (K-9), entity 17842709
-- Shellfish : Yahse Hunting Grounds, entities 17842713-17842722
-- !addquest 9 5
-----------------------------------
-- Retail (bg-wiki "Don't Clam Up on Me Now").
-- |Start=Oblor, Yahse Hunting Grounds - (K-9)  |Previous=None  |Repeatable=No
-- |Fame=Adoulin  |FLevel=1  |Reward=1000 Experience Points
--   1. Speak to Oblor (K-9) at the Frontier Station.
--   2. Collect five Shellfish from one of the beaches on the east side of the map.
--      "(K-7) has a beach with Orobons... (K-8) has a beach with Uragnites."
--      "Note that you cannot zone during or after collecting the required
--      shellfish as they will all be lost."
--      "Locations are semi-random and the same clam can't be collected twice,
--      either by the same player or by two different players. A replacement will
--      immediately spawn on the same beach."
--   3. Return to Oblor for your reward to complete the quest.
--
-- CSIDS DECODED, NOT GUESSED -- AND THE DUMP'S ZONE LABELS ARE OFF BY ONE HERE.
-- Oblor is 17842709 -> zone 260 idx 533 (0x01104215). `xi-dat events 260` gives
-- him 2500, 2501, 2502, 2503, 2504. The ten Shellfish own no csids at all, which
-- is why the gathering below is messages rather than events.
--
-- The dumped dialog file labelled zone N holds zone N-1's text for the Adoulin
-- field zones. The offset is pinned by this repo's own known-correct ids, not by
-- my reading: Yahse_Hunting_Grounds/IDs.lua has WAYPOINT_ATTUNED = 7619 and
-- Ceizak_Battlegrounds/IDs.lua has 7599, and in the dumps 7619 is the attunement
-- line in the file labelled 261 (Yahse is zone 260) while 7599 is the attunement
-- line in the file labelled 262 (Ceizak is 261). Read against file 261:
--   2500 -> 7504-7508  THE OFFER. 7504 "one of our most important tasks in
--          supporting the colonization efforts is securing proper rations",
--          7505 "Edible shellfish inhabit the surrounding oceans", 7507 "I want
--          you to go collect some shellfish to help shore up my supply", and
--          7508 "The shellfish are found on the surrounding beaches. We're
--          telling everyone who comes by to collect five". No ${selection-lines},
--          so speaking to him starts it.
--   2501 -> 7508       the reminder: five, from the beaches.
--   2502 -> 7509-7514  THE TURN-IN. 7509 "one, two, three, four...five! Five
--          shellfish! Ah ah ah!", then the running joke about the black ones
--          going to the Scouts' Coalition, closing on 7514 "Here's something for
--          your trouble."
--   2503/2504 -> 7515  "Large, succulent shellfish line the beach." -- his idle.
--   Gathering messages, same table: 7516 "You collect a shellfish from the
--          ground. (${number: 0} of 5)", 7517 "You already have enough
--          shellfish.", 7518 "The shellfish disappeared."
--
-- THE COUNT OF FIVE IS THE EVENT'S OWN. 7508 states it in prose and 7516 renders
-- it as a literal "of 5", so nothing needs passing from Lua; csidmsg.load() shows
-- Oblor's block carries its own data[] = [65, 7504..7514, 201, 0, 7515].
--
-- ZONING LOSES THE CATCH, per bg-wiki, which is why the tally is a local var --
-- local vars do not survive a zone change, so the reset is automatic rather than
-- something this script has to remember to do.
--
-- ONE CLAM, ONE TAKER. bg-wiki is explicit that a given shellfish cannot be
-- collected twice "either by the same player or by two different players", and
-- that a replacement spawns immediately. That is a property of the entity, not of
-- the player, so the cooldown is stamped on the Shellfish itself; any player who
-- reaches it first takes it, and it becomes available again after the respawn.
-----------------------------------
local yahseID = zones[xi.zone.YAHSE_HUNTING_GROUNDS]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.DONT_CLAM_UP_ON_ME_NOW)

local shellfishNeeded = 5
local respawnSeconds  = 30 -- "A replacement will immediately spawn on the same beach."

quest.reward =
{
    exp      = 1000,
    fameArea = xi.fameArea.ADOULIN,
}

quest.sections =
{
    -- bg-wiki lists |Previous=None, and |FLevel=1 is the base fame level every
    -- character already has, so there is no fame gate to apply.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Oblor'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2500)
                end,
            },

            onEventFinish =
            {
                [2500] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:setLocalVar('ClamUpShellfish', 0)
                end,
            },
        },
    },

    -- Accepted: comb the beaches for five, then take them to Oblor.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Shellfish'] =
            {
                onTrigger = function(player, npc)
                    local collected = player:getLocalVar('ClamUpShellfish')

                    if collected >= shellfishNeeded then
                        player:messageSpecial(yahseID.text.ALREADY_ENOUGH_SHELLFISH)
                        return
                    end

                    -- The clam itself remembers being taken, so a second player
                    -- cannot collect the same one until it has respawned.
                    local now = GetSystemTime()
                    if now < npc:getLocalVar('ShellfishTaken') then
                        player:messageSpecial(yahseID.text.SHELLFISH_DISAPPEARED)
                        return
                    end

                    npc:setLocalVar('ShellfishTaken', now + respawnSeconds)
                    collected = collected + 1
                    player:setLocalVar('ClamUpShellfish', collected)
                    player:messageSpecial(yahseID.text.COLLECT_SHELLFISH, collected)
                end,
            },

            ['Oblor'] =
            {
                onTrigger = function(player, npc)
                    if player:getLocalVar('ClamUpShellfish') >= shellfishNeeded then
                        return quest:progressEvent(2502)
                    end

                    return quest:event(2501)
                end,
            },

            onEventFinish =
            {
                [2502] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setLocalVar('ClamUpShellfish', 0)
                    end
                end,
            },
        },
    },

    -- Completed: 7515, the beach itself.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.YAHSE_HUNTING_GROUNDS] =
        {
            ['Oblor'] = quest:event(2503):replaceDefault(),
        },
    },
}

return quest
