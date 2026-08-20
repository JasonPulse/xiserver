-----------------------------------
--  Incessant Void
--  Description: Deals damage and grants the caster a Magic Barrier.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Deals damage. Gains Magic Barrier."
--   Notes: "Can be staggered to remove the Magic Barrier from Incessant Void."
--
-- MODELLED ON: great_whirlwind.lua for damage; the self-buff uses xi.effect.MAGIC_SHIELD,
-- which is the repo's Magic Barrier equivalent, applied to the MOB rather than
-- the target.
-- Element: bg-wiki leaves Class and Type blank for this ability, so DARK is
-- used -- Hades is a dark-themed Supreme Being and DARK is the repo's default
-- for untyped mob magic (implosion.lua does the same). Called out rather than
-- presented as sourced.
-- The blue-stagger removal bg-wiki mentions is not implemented -- that belongs
-- to the stagger system, not this skill.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.DARK, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    mob:addStatusEffect(xi.effect.MAGIC_SHIELD, 1, 0, 60)

    return damage
end

return mobskillObject
