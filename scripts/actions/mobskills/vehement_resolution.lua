-----------------------------------
-- Vehement Resolution
-- Description: Morimar's emergency move (used below 50% HP). Fully restores his own HP,
--              removes his debuffs, and grants him a Regen aura.
-- Type: Self-target (healing)
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    -- Full self-heal.
    mob:addHP(mob:getMaxHP() - mob:getHP())

    -- Wipe his own debuffs.
    mob:delStatusEffectsByFlag(xi.effectFlag.ERASABLE, false)

    -- Grant a Regen aura (30 HP/tick for 60s).
    mob:addStatusEffect(xi.effect.REGEN, 30, 3, 60)

    skill:setMsg(xi.msg.basic.SELF_HEAL)

    return 0
end

return mobskillObject
