-----------------------------------
--  Impudence
--  Description: Deals damage. Additional effect: Curse.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Damage + Curse (Recovery)"
--
-- MODELLED ON: great_whirlwind.lua for damage; CURSE_II is the repo's "Curse
-- (Recovery down)" effect, as distinct from CURSE (max HP down).
-- Element: bg-wiki leaves Class and Type blank for this ability, so DARK is
-- used -- Hades is a dark-themed Supreme Being and DARK is the repo's default
-- for untyped mob magic (implosion.lua does the same). Called out rather than
-- presented as sourced.
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

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.CURSE_II, 1, 0, 60)

    return damage
end

return mobskillObject
