-----------------------------------
-- Area: Morimar Basalt Fields
--  Mob: Achuka (Wildskeeper Naakual)
-----------------------------------
require('scripts/globals/wildskeeper_reives')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.wildskeeperReives.grantRewards(mob, player)
end

return entity
