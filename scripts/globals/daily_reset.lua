-----------------------------------
-- Daily currency / counter reset hook.
--
-- Run from xi.player.onGameIn on login (not on every zone-in). Resets the
-- cumulative daily counters that aren't self-rotating via
-- VanadielUniqueDay() comparisons.
--
-- Cumulative counters needing reset:
--   * domain_points_daily — capped at 600 per day; cap-check in
--     xi.domainInvasion.grantPoints. Without reset, players permanently
--     hit cap after day 1.
--
-- Self-rotating (no reset needed):
--   * Coalition_Task_Daily — stores last-claimed day, compared at trigger
--   * Bastion_Daily_<zoneId> — same pattern
--   * Login Campaign — handled by xi.events.loginCampaign.onGameIn
-----------------------------------
xi = xi or {}
xi.dailyReset = xi.dailyReset or {}

local lastResetVar = 'Last_Daily_Reset'

xi.dailyReset.check = function(player)
    if not player then
        return
    end

    local today     = VanadielUniqueDay()
    local lastReset = player:getCharVar(lastResetVar)

    if today <= lastReset then
        return
    end

    -- Cumulative counter resets
    local dailyDP = player:getCurrency('domain_points_daily')
    if dailyDP > 0 then
        player:delCurrency('domain_points_daily', dailyDP)
    end

    player:setCharVar(lastResetVar, today)
end
