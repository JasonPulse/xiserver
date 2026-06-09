-----------------------------------
-- Adoulin Coalition rank API
--
-- Backed by CharVars. Read by C++ in COLONIZATION packet
-- (src/map/packets/s2c/0x071_influence_colonization.cpp). When you change
-- a rank here the client sees it on the next colonization packet send.
--
-- Usage:
--   local rank = xi.coalition.getRank(player, xi.coalition.PIONEERS)
--   xi.coalition.setRank(player, xi.coalition.PIONEERS, 5)
--   xi.coalition.addRank(player, xi.coalition.PIONEERS, 1)
--   xi.coalition.spendImprimaturs(player, 100)
--
-- For GM testing:
--   !setvar Coalition_Pioneers_Rank 10
-----------------------------------
xi = xi or {}
xi.coalition = xi.coalition or {}

local function varFor(coalition)
    local name = xi.coalition.varNames[coalition]
    if not name then
        error(string.format('Unknown coalition id: %s', tostring(coalition)))
    end

    return name
end

local function clampRank(rank)
    if rank < 0 then
        return 0
    end

    if rank > xi.coalition.MAX_RANK then
        return xi.coalition.MAX_RANK
    end

    return rank
end

-- Returns 0..15 (CharVar default is 0 for new chars).
xi.coalition.getRank = function(player, coalition)
    return player:getCharVar(varFor(coalition))
end

xi.coalition.setRank = function(player, coalition, rank)
    player:setCharVar(varFor(coalition), clampRank(rank))
end

xi.coalition.addRank = function(player, coalition, amount)
    xi.coalition.setRank(player, coalition, xi.coalition.getRank(player, coalition) + amount)
end

-- Returns a table keyed by xi.coalition.* with the current rank values.
xi.coalition.getAllRanks = function(player)
    local out = {}
    for coalition, _ in pairs(xi.coalition.varNames) do
        out[coalition] = xi.coalition.getRank(player, coalition)
    end

    return out
end

-- Imprimaturs have two related state pieces:
--
--   * Balance — the currency the player holds. Tracked in char_points.imprimaturs;
--     read/write via player:getCurrency/addCurrency/delCurrency('imprimaturs').
--   * Spent counter — lifetime total spent, used for SOA mission progression
--     gates and Iyvah Halohm's display. Tracked in CharVar Coalition_Imprimaturs_Spent.
--
-- The two are linked by spendImprimaturs(): it deducts the balance AND bumps
-- the counter atomically. Use getImprimatursBalance / getImprimatursSpent
-- to inspect either independently.

xi.coalition.getImprimatursBalance = function(player)
    return player:getCurrency('imprimaturs')
end

xi.coalition.addImprimatursBalance = function(player, amount)
    player:addCurrency('imprimaturs', amount)
end

xi.coalition.getImprimatursSpent = function(player)
    return player:getCharVar(xi.coalition.IMPRIMATURS_VAR)
end

xi.coalition.addImprimatursSpent = function(player, amount)
    player:incrementCharVar(xi.coalition.IMPRIMATURS_VAR, amount)
end

-- Real spend: returns true if the player had enough balance and both the
-- deduction and counter bump happened, false otherwise.
xi.coalition.spendImprimaturs = function(player, amount)
    if xi.coalition.getImprimatursBalance(player) < amount then
        return false
    end

    player:delCurrency('imprimaturs', amount)
    xi.coalition.addImprimatursSpent(player, amount)
    return true
end

-- Returns (coalitionId, rank) for the coalition with the lowest non-zero
-- rank (i.e. the next one to advance for an unbiased player). Ties broken
-- by enum order so behavior is deterministic. Returns nil if the player
-- is not yet registered in any coalition.
xi.coalition.lowestRank = function(player)
    local bestId, bestRank
    for coalition = xi.coalition.PIONEERS, xi.coalition.MUMMERS do
        local rank = xi.coalition.getRank(player, coalition)
        if rank > 0 and (bestRank == nil or rank < bestRank) then
            bestId   = coalition
            bestRank = rank
        end
    end

    return bestId, bestRank
end

-- Cost to advance the given coalition by one rank. nil at MAX_RANK.
xi.coalition.rankUpCost = function(player, coalition)
    local rank = xi.coalition.getRank(player, coalition)
    return xi.coalition.RANK_UP_COSTS[rank]
end

-- Returns the coalition id the player has pinned via the EDIFY_TARGET_VAR
-- CharVar (1..6), or nil if unset/invalid. Does NOT check whether the
-- pinned coalition is at max rank — callers should report 'maxed' against
-- the pin so the player sees an actionable message instead of silently
-- switching to a different coalition.
local function pinnedTarget(player)
    local pinned = player:getCharVar(xi.coalition.EDIFY_TARGET_VAR)
    if pinned >= xi.coalition.PIONEERS and pinned <= xi.coalition.MUMMERS then
        return pinned
    end

    return nil
end

-- Edification: spend imprimaturs to advance one rank. Picks the player's
-- pinned target if set, otherwise the lowest non-zero coalition. Returns:
--   true,  coalition, newRank, cost          on success
--   false, reason, coalition, cost
-- where reason is one of: 'unregistered', 'maxed', 'insufficient'.
xi.coalition.edify = function(player)
    local target = pinnedTarget(player)
    if not target then
        local lowestId, lowestRank = xi.coalition.lowestRank(player)
        if not lowestId then
            return false, 'unregistered'
        end

        if lowestRank >= xi.coalition.MAX_RANK then
            return false, 'maxed', lowestId
        end

        target = lowestId
    end

    local cost = xi.coalition.rankUpCost(player, target)
    if cost == nil then
        return false, 'maxed', target
    end

    if not xi.coalition.spendImprimaturs(player, cost) then
        return false, 'insufficient', target, cost
    end

    xi.coalition.addRank(player, target, 1)
    return true, target, xi.coalition.getRank(player, target), cost
end
