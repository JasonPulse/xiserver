-----------------------------------
-- Ported from Mishffera/lsb-server (https://github.com/Mishffera/lsb-server)
-- Source of Silver Sea Remnants + Lebros Assault content; adapted to this fork.
-----------------------------------
-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Staggering Sapling
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller then
        xi.salvage.spawnTempChest(mob, {})
    end
end

return entity
