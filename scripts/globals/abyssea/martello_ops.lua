-----------------------------------
-- Abyssea martello operations: Refuel and Replenish, A Mightier Martello.
--
-- Eighteen quests, two in each of the nine Abyssea field zones, all built from one
-- spec because they differ only in zone, fame area, tower names and which pair of key
-- items is carried. bg-wiki gives them one shared walkthrough:
--
--   1. Speak to the Machine Outfitter and choose "Assist with replenishment" or
--      "Assist with upgrades" to accept.
--   2. Receive the Vat of martello fuel, or the Fuel reservoir for an upgrade.
--      "You cannot zone at any point during the quest, or you lose the key item and
--       you must restart."
--   3. Find any martello in the zone and work on it. "It is possible to replenish it
--      even if it is already at 100% health."
--   4. The vat becomes an Empty fuel vat, the reservoir a Cracked fuel reservoir.
--   5. Report to the Machine Outfitter.
--
--   "Only one Refuel and Replenish or A Mightier Martello quest can be completed per
--    Vana'dielian day, regardless of Abyssea area." That limit is shared across all
--    eighteen, so it lives on one CharVar here rather than per quest.
--
-- WHY THIS DRIVES THE TOWERS WITH printToPlayer RATHER THAN THEIR REAL MENU.
-- The tower menu IS decoded now, message 7577, twelve options with "Prepare to
-- replenish martello" at 4 and the direction picks at 6 and 7, and the option mask
-- reaches it as startEvent parameter 0 (see reference-martello-menu-decoded). What
-- could not be established is how the client behaves when the server supplies a mask
-- it has not verified, and that cannot be tested from here: the agent bridge injects
-- an OUTGOING 0x05B, which tells the SERVER what was picked but does not advance the
-- client's own event program, so a menu cannot be driven or observed without a human
-- at the screen. Firing an unproven event at a player risks a window that renders
-- nothing. So these use the same printToPlayer path that martello.lua and Of
-- Malnourished Martellos already use, and reproduce the OUTCOMES bg-wiki specifies.
-- Switching to the real menu later is a change to this one file.
--
-- THE CRUOR FIGURES ARE OURS. bg-wiki says only "varying amount of cruor depending on
-- which martello you choose" and "depending on the direction the upgrade is completed
-- from", and publishes no table, so the band below is tuning in the same spirit as
-- martello.lua's regeneration rate.
-----------------------------------
require('scripts/globals/npc_util')
require('scripts/globals/quests')
-----------------------------------

xi = xi or {}
xi.martelloOps = xi.martelloOps or {}

xi.martelloOps.op =
{
    REFUEL  = 1,
    UPGRADE = 2,
}

-- Shared across all eighteen quests, which is the point of it.
local dailyVar = 'Martello_Op_Day'

local cruorFloor = 200
local cruorCeil  = 500

local carried =
{
    [xi.martelloOps.op.REFUEL]  = { given = xi.ki.VAT_OF_MARTELLO_FUEL, spent = xi.ki.EMPTY_FUEL_VAT },
    [xi.martelloOps.op.UPGRADE] = { given = xi.ki.FUEL_RESERVOIR,       spent = xi.ki.CRACKED_FUEL_RESERVOIR },
}

local offerText =
{
    [xi.martelloOps.op.REFUEL]  = 'The machine outfitter hands you a vat of martello fuel. Find a martello and empty it into the intake.',
    [xi.martelloOps.op.UPGRADE] = 'The machine outfitter hands you a fuel reservoir. Find a martello and fit it to the tower.',
}

local workText =
{
    [xi.martelloOps.op.REFUEL]  = 'You empty the vat into the martello fuel intake. The tower thrums as it drinks.',
    [xi.martelloOps.op.UPGRADE] = 'You fit the reservoir into the martello housing. The tower settles around its new capacity.',
}

--- True once this player has already closed a martello operation today. bg-wiki
--- applies the limit across every Abyssea area, not per zone.
local function doneToday(player)
    return player:getCharVar(dailyVar) >= VanadielUniqueDay()
end

--- Build the whole sections table for one martello operation quest.
---@param quest table the Quest object
---@param spec table zone, fameArea, fameLevel, towers, mode
---@return table sections
xi.martelloOps.sections = function(quest, spec)
    local keyItems = carried[spec.mode]

    local function clearRun(player)
        player:delKeyItem(keyItems.given)
        player:delKeyItem(keyItems.spent)
    end

    local function accept(player)
        clearRun(player)
        npcUtil.giveKeyItem(player, keyItems.given)
        player:printToPlayer(offerText[spec.mode], xi.msg.channel.NS_SAY)
    end

    local function payOut(player)
        clearRun(player)
        xi.abyssea.questReward(player, math.random(cruorFloor, cruorCeil), nil)
        player:setCharVar(dailyVar, VanadielUniqueDay())
    end

    -- Working a tower. Any of the zone's numbered martellos will do; bg-wiki is
    -- explicit that its current energy does not matter.
    local towerActions =
    {
        onTrigger = function(player, npc)
            if not player:hasKeyItem(keyItems.given) then
                return
            end

            player:delKeyItem(keyItems.given)
            npcUtil.giveKeyItem(player, keyItems.spent)
            player:printToPlayer(workText[spec.mode], xi.msg.channel.NS_SAY)

            return true
        end,
    }

    --- "You cannot zone at any point during the quest, or you lose the key item."
    local function loseOnZone(player, prevZone)
        if player:hasKeyItem(keyItems.given) or player:hasKeyItem(keyItems.spent) then
            clearRun(player)
        end
    end

    local function zoneTable(trigger, finishes)
        local zone =
        {
            ['Machine_Outfitter'] = { onTrigger = trigger },
            onZoneIn = loseOnZone,
            onEventFinish = finishes,
        }

        for _, tower in ipairs(spec.towers) do
            zone[tower] = towerActions
        end

        return zone
    end

    return
    {
        {
            check = function(player, status, vars)
                -- spec.prereq is set only where bg-wiki names one, which is the
                -- Konschtat pair: "this quest is part of a series of quest."
                if
                    spec.prereq ~= nil and
                    player:getQuestStatus(xi.questLog.ABYSSEA, spec.prereq) ~= xi.questStatus.QUEST_COMPLETED
                then
                    return false
                end

                return status == xi.questStatus.QUEST_AVAILABLE and
                    player:getFameLevel(spec.fameArea) >= spec.fameLevel and
                    not doneToday(player)
            end,

            [spec.zone] =
            {
                ['Machine_Outfitter'] =
                {
                    onTrigger = function(player, npc)
                        quest:begin(player)
                        accept(player)

                        return true
                    end,
                },
            },
        },

        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_ACCEPTED
            end,

            [spec.zone] = zoneTable(function(player, npc)
                if not player:hasKeyItem(keyItems.spent) then
                    -- Lost the vat to a zone line, so he simply issues another.
                    if not player:hasKeyItem(keyItems.given) then
                        accept(player)
                    end

                    return true
                end

                if quest:complete(player) then
                    payOut(player)
                end

                return true
            end, {}),
        },

        {
            check = function(player, status, vars)
                return status == xi.questStatus.QUEST_COMPLETED
            end,

            [spec.zone] = zoneTable(function(player, npc)
                if player:hasKeyItem(keyItems.spent) then
                    payOut(player)

                    return true
                end

                if player:hasKeyItem(keyItems.given) then
                    return true
                end

                if doneToday(player) then
                    player:printToPlayer('The machine outfitter has no further work for you today.', xi.msg.channel.NS_SAY)

                    return true
                end

                accept(player)

                return true
            end, {}),
        },
    }
end
