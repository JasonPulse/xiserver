-----------------------------------
-- Area: Western Adoulin
--  NPC: Task Delegator
-- Type: Coalition Assignments / Lights grantor + Edification (simplified stub).
--
-- Retail: hands out Coalition Assignments ("Lights") — daily/weekly tasks
-- that pay imprimaturs. Edification (paying imprimaturs to advance rank) is
-- handled by per-coalition rep NPCs that don't exist in our npc_list.
--
-- Our stub does both jobs from one NPC:
--   1. Once-per-Vana'diel-day claim adds CURRENCY_REWARD to the imprimaturs
--      balance and IMPRIMATURS_REWARD to the lifetime-spent counter (which
--      drives SOA mission gates and Iyvah Halohm's display).
--   2. If the player has pinned a coalition via the EDIFY_TARGET_VAR CharVar
--      (e.g. `!setvar Coalition_Edify_Target 1` for Pioneers) and has enough
--      imprimaturs, advance them by one rank and report the result. No pin
--      = no auto-spend, so players don't accidentally burn imprimaturs.
--
-- Requires Civil_Registrar registration first.
--
-- Tunables: edit the constants below if the pacing feels off.
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
---@type TNpcEntity
local entity = {}

local dailyClaimVar     = 'Coalition_Task_Daily'
local imprimatursReward = 10  -- credited to spent counter
local currencyReward    = 100 -- credited to imprimaturs balance

local function isRegistered(player)
    for coalitionId, _ in pairs(xi.coalition.varNames) do
        if xi.coalition.getRank(player, coalitionId) > 0 then
            return true
        end
    end

    return false
end

local function processDailyClaim(player)
    local today     = VanadielUniqueDay()
    local lastClaim = player:getCharVar(dailyClaimVar)

    if lastClaim >= today then
        player:printToPlayer('You have already completed an assignment today.')
        return
    end

    xi.coalition.addImprimatursBalance(player, currencyReward)
    xi.coalition.addImprimatursSpent(player, imprimatursReward)
    player:setCharVar(dailyClaimVar, today)

    player:printToPlayer(string.format(
        'Assignment complete. You receive %d imprimaturs (lifetime spent now %d).',
        currencyReward, xi.coalition.getImprimatursSpent(player)))
end

local function processEdification(player)
    local pinned = player:getCharVar(xi.coalition.EDIFY_TARGET_VAR)
    if pinned < xi.coalition.PIONEERS or pinned > xi.coalition.MUMMERS then
        return
    end

    local ok, coalitionOrReason, coalitionOrNewRank, cost = xi.coalition.edify(player)
    if ok then
        local coalition = coalitionOrReason
        local newRank   = coalitionOrNewRank
        player:printToPlayer(string.format(
            'You have been edified — %s advance to rank %d (spent %d imprimaturs).',
            xi.coalition.displayNames[coalition], newRank, cost))
        return
    end

    local reason    = coalitionOrReason
    local coalition = coalitionOrNewRank

    if reason == 'maxed' then
        player:printToPlayer(string.format(
            '%s rank is already at the maximum (%d).',
            xi.coalition.displayNames[coalition], xi.coalition.MAX_RANK))
    elseif reason == 'insufficient' then
        player:printToPlayer(string.format(
            'You need %d imprimaturs to advance %s to rank %d.',
            cost, xi.coalition.displayNames[coalition],
            xi.coalition.getRank(player, coalition) + 1))
    end
end

entity.onTrigger = function(player, npc)
    if not isRegistered(player) then
        player:printToPlayer('Speak to a Civil Registrar to enroll with the coalitions before accepting assignments.')
        return
    end

    processDailyClaim(player)
    processEdification(player)
end

return entity
