-----------------------------------
--  Crippling Agony
--  Description: Deals damage. Additional effect: Bind.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Damage + Bind" | Condition: Wings extended.
--
-- MODELLED ON: great_whirlwind.lua for damage plus the standard mob Bind block.
-- Element: bg-wiki leaves Class and Type blank for this ability, so DARK is
-- used -- Hades is a dark-themed Supreme Being and DARK is the repo's default
-- for untyped mob magic (implosion.lua does the same). Called out rather than
-- presented as sourced.
-- Bind 1 / 0 / 30 is the common mob Bind. Wing-state not gated; see
-- tenbrous_grip.lua.
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

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BIND, 1, 0, 30)

    return damage
end

return mobskillObject
