-----------------------------------
-- Area: Al Zahbi
--  Mob: Thunderclap Sareel Ja
-----------------------------------
require('scripts/globals/besieged')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Thunderbolt_Piraal_Ja')
end

entity.onMobDeath = function(mob, player, optParams)
    xi.besieged.grantSimplifiedReward(mob, player, 'Thunderclap Sareel Ja')
end

return entity
