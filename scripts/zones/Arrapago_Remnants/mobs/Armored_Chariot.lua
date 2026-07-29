-----------------------------------
-- Ported from Mishffera/lsb-server (https://github.com/Mishffera/lsb-server)
-- Source of Silver Sea Remnants + Lebros Assault content; adapted to this fork.
-----------------------------------
-----------------------------------
-- Area: Arrapago Remnants
--   NM: Armored Chariot
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.SUN_CHARIOTEER)
    end
end

return entity
