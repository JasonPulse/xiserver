-----------------------------------
-- Area: Al Zahbi
--  Mob: Mamool Ja Cataphract
-----------------------------------
require('scripts/globals/besieged')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.pet.setMobPet(mob, 1, 'Mamool_Jas_Wyvern')
end

entity.onMobDeath = function(mob, player, optParams)
    xi.besieged.grantSimplifiedReward(mob, player, 'Mamool Ja Cataphract')
end

return entity
