-----------------------------------
-- Area: Escha - Ru'Aun (289)
--  Mob: Ark Angel EV (Geas Fete pop)
-----------------------------------
require('scripts/globals/geas_fete')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.geasFete.grantRewards(mob, player)
end

return entity
