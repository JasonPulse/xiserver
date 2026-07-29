-----------------------------------
-- Ported from Mishffera/lsb-server (https://github.com/Mishffera/lsb-server)
-- Source of Silver Sea Remnants + Lebros Assault content; adapted to this fork.
-----------------------------------
-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Merrow Kabukidancer
-----------------------------------
mixins = { require('scripts/mixins/weapon_break') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    if optParams.isKiller then
        local instance = mob:getInstance()

        if instance and instance:getStage() == 1 then
            instance:setProgress(instance:getProgress() + 1)
        end

        if instance then
            xi.salvage.spawnTempChest(mob, {})
        end
    end
end

entity.onMobDespawn = function(mob)
end

return entity
