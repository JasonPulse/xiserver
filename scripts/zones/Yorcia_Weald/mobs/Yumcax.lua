-----------------------------------
-- Area: Yorcia Weald (263)
--  Mob: Yumcax (Wildskeeper Naakual + Domain Invasion rotation NM)
--
-- Yumcax has dual roles: a WKR pop fight (consume Resurrection Retardant Axe
-- KI) and a Domain Invasion rotation entry. The same mob entity backs both
-- — we grant both reward streams unconditionally on death so players don't
-- miss the WKR bayld stipend if they only popped for that.
-----------------------------------
require('scripts/globals/domain_invasion')
require('scripts/globals/wildskeeper_reives')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.grantPoints(mob, player)
    xi.wildskeeperReives.grantRewards(mob, player)
end

return entity
