-----------------------------------
-- Abyssea Bastion (simplified)
--
-- Retail: a defense mini-game where players protect a node against waves of
-- enemies; success grants bonus cruor + lights. Implementing the full wave
-- system requires mob spawn waves + objective tracking + ranking, all of
-- which need in-game tuning we don't have.
--
-- Our stub: Bastion_Prefect NPC grants a flat once-per-Vana'diel-day cruor
-- stipend per zone (Konschtat / La Theine / Tahrongi). Players who actively
-- visit the three Prefects get an additional cruor income source on top of
-- Sturdy Pyxis grabs.
--
-- A future build can extend this with real wave mechanics; the daily-claim
-- pattern matches what Task_Delegator does for Adoulin imprimaturs.
-----------------------------------
xi = xi or {}
xi.bastion = xi.bastion or {}

local dailyClaimVarPrefix = 'Bastion_Daily_'
local cruorStipend        = 5000

xi.bastion.onTrigger = function(player, npc)
    local zoneId = player:getZoneID()
    local ID     = zones[zoneId]

    if not player:hasStatusEffect(xi.effect.VISITANT) then
        player:messageSpecial(ID.text.NO_VISITANT_STATUS)
        return
    end

    local today     = VanadielUniqueDay()
    local varName   = dailyClaimVarPrefix .. tostring(zoneId)
    local lastClaim = player:getCharVar(varName)

    if lastClaim >= today then
        player:printToPlayer('The Bastion Prefect has no further orders for you today. Return at midnight (Vana\'diel).')
        return
    end

    player:addCurrency('cruor', cruorStipend)
    player:setCharVar(varName, today)
    player:messageSpecial(ID.text.CRUOR_OBTAINED, cruorStipend)
end
