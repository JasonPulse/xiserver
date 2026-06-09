-----------------------------------
-- Area: Escha - Ru'Aun (289)
--  Mob: Naga Raja (Domain Invasion rotation + standard Escha NM)
--
-- Naga_Raja appears in the Domain Invasion rotation. It's not a standard
-- Geas Fete pop in retail, but the death distribution still drops onto the
-- general DI flow so points are awarded.
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.domainInvasion.grantPoints(mob, player)
end

return entity
