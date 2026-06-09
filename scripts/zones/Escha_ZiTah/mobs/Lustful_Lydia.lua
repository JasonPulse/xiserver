-----------------------------------
-- Area: Escha - Zi'Tah (288)
--  Mob: Lustful Lydia (Geas Fete pop)
-----------------------------------
require('scripts/globals/geas_fete')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.geasFete.grantRewards(mob, player)
end

return entity
