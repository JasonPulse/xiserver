-----------------------------------
-- Area: Western Adoulin
--  NPC: Task Delegator
-- Type: Coalition Assignments / Lights grantor (simplified stub).
--
-- Retail: hands out Coalition Assignments ("Lights") — daily/weekly tasks
-- that pay imprimaturs as currency on completion.
--
-- Our stub: one click per Vana'diel day grants a fixed reward representing
-- a completed assignment. Adds to both the imprimatur currency balance and
-- the lifetime-spent counter (which drives SOA mission gates and Iyvah
-- Halohm's display). Requires Civil_Registrar registration first.
--
-- Tunables: edit the constants below if the pacing feels off.
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
---@type TNpcEntity
local entity = {}

local DAILY_CLAIM_VAR    = 'Coalition_Task_Daily'
local IMPRIMATURS_REWARD = 10  -- credited to balance AND spent counter
local CURRENCY_REWARD    = 100 -- credited to imprimaturs balance only

local function isRegistered(player)
    for coalitionId, _ in pairs(xi.coalition.varNames) do
        if xi.coalition.getRank(player, coalitionId) > 0 then
            return true
        end
    end
    return false
end

entity.onTrigger = function(player, npc)
    if not isRegistered(player) then
        player:printToPlayer('Speak to a Civil Registrar to enroll with the coalitions before accepting assignments.')
        return
    end

    local today      = VanadielUniqueDay()
    local lastClaim  = player:getCharVar(DAILY_CLAIM_VAR)

    if lastClaim >= today then
        player:printToPlayer('You have already completed an assignment today. Return tomorrow.')
        return
    end

    xi.coalition.addImprimatursBalance(player, CURRENCY_REWARD)
    xi.coalition.addImprimatursSpent(player, IMPRIMATURS_REWARD)
    player:setCharVar(DAILY_CLAIM_VAR, today)

    player:printToPlayer(string.format(
        'Assignment complete. You receive %d imprimaturs (lifetime spent now %d).',
        CURRENCY_REWARD, xi.coalition.getImprimatursSpent(player)))
end

return entity
