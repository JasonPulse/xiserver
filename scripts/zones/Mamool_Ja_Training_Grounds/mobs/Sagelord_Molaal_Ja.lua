-----------------------------------
-- Area: Mamool Ja Training Grounds (Sagelord Elimination)
--  Mob: Sagelord Molaal Ja
-----------------------------------
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    local instance = mob:getInstance()
    if not instance then
        return
    end

    -- Completing the objective: kill the Sagelord.
    instance:setProgress(instance:getProgress() + 1)
end

return entity
