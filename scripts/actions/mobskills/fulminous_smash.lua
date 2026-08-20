-----------------------------------
--  Fulminous Smash
--  Description: Deals Thunder damage in an area of effect. Additional effect: Stun and Knockback.
--  Type: Magical
--  Range: 10' radial
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area AoE 10' | Target Player | Class magical | Type thunder
--   Effect: "Damage, Stun, and Knockback" | no HP condition
--
-- MODELLED ON: thunderbolt-class magical AoE with Stun. Damage formula and the
-- mobStatusEffectMove(STUN) shape are taken from great_whirlwind.lua, which is the
-- repo's standard "magical element damage + one status" skill.
-- Knockback is NOT applied from Lua -- there is no such binding. It is
-- driven by the `knockback` column of the mob_skills row (column 12, read by
-- LoadMobSkillsList in battleutils.cpp and surfaced as skill:getKnockback()).
-- That column is 0 for every Hades skill because all 18 rows are auto-generated
-- placeholders, so it is set to 1 for this one in sql/mob_skills.sql: bg-wiki
-- states knockback occurs, making 0 definitely wrong, and 1 is the minimum
-- non-zero step rather than a guessed magnitude.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.THUNDER, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.THUNDER, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.THUNDER)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STUN, 1, 0, 5)

    return damage
end

return mobskillObject
