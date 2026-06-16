-----------------------------------
-- Area: Cirdas Caverns [U]
--  Mob: Mistmaw Xelhua (Alluvion Skirmish boss)
-----------------------------------
require('scripts/globals/skirmish')
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.skirmish.grantStoneDrop(mob, player, { 'leaf', 'snow' })
end

return entity
