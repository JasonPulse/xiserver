-----------------------------------
-- Area: Escha - Ru'Aun (289)
--  Mob: Naga Raja (Domain Invasion rotation NM)
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.grantPoints(mob, player)
end

return entity
