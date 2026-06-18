-----------------------------------
-- Area: Abyssea - Konschtat (15)
--   NM: Eccentric Eve
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    player:addTitle(xi.title.ECCENTRICITY_EXPUNGER)
    xi.abyssea.grantAtmaDrop(mob, player, xi.ki.ATMA_OF_THE_VORACIOUS_VIOLET)
end

return entity
