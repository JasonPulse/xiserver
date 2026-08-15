-----------------------------------
-- Area: Ilrusi Atoll (Lamia No.13)
--  Mob: Lamia No.13
-----------------------------------
-- The sole objective of the Lamia No.13 assault (instance 5501) is to eliminate
-- her, so her death is the whole win condition: bump instance progress and
-- lamia_no_13.lua's onInstanceProgressUpdate completes at 1.
--
-- Progress is bumped in onMobDeath rather than onMobDespawn. This zone's
-- Carrion_* mobs use onMobDespawn because Extermination counts a population and
-- randomly substitutes an Undead spawn on despawn; there is nothing to substitute
-- here, and using death means the assault closes the moment she drops instead of
-- waiting on the despawn timer.
--
-- Guarded on getInstance() being non-nil: mob_groups gives her respawn 0, so she
-- is pop-only and normally exists only inside the instance, but the guard keeps a
-- GM spawn outside one from erroring.
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    local instance = mob:getInstance()

    if not instance then
        return
    end

    instance:setProgress(instance:getProgress() + 1)
end

return entity
