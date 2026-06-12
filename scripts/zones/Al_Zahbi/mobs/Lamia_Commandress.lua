-----------------------------------
-- Area: Al Zahbi
--  Mob: Lamia Commandress
-----------------------------------
require('scripts/globals/besieged')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Lamias_Elemental')
end

entity.onMobDeath = function(mob, player, optParams)
    xi.besieged.grantSimplifiedReward(mob, player, 'Lamia Commandress')
end

return entity
