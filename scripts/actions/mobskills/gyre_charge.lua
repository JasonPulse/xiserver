-----------------------------------
--  Gyre Charge
--  Description: Deals physical damage in an area of effect. Additional effects: Paralysis and Knockback.
--  Type: Physical
--  Range: Radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Gyre Charge {{physical}} AoE damage with additional effect Paralyze and
--    Knockback."
--
-- MODELLED ON: a standard physical AoE weaponskill -- mobPhysicalMove rather than
-- mobMagicalMove, because bg-wiki tags this one {{physical}} while every other
-- Shinryu ability is {{magical}}.
-- Knockback is NOT applied from Lua (no such binding exists); it comes from the
-- `knockback` column of the mob_skills row, read as skill:getKnockback(). It is
-- set to 1 for this skill in sql/mob_skills.sql, the minimum non-zero step, since
-- bg-wiki states knockback occurs but gives no magnitude.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, 1, 1, 1, xi.mobskills.physicalTpBonus.NO_EFFECT, 1, 1, 1)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.BLUNT, xi.mobskills.shadowBehavior.NUMSHADOWS_1)

    target:takeDamage(damage, mob, xi.attackType.PHYSICAL, xi.damageType.BLUNT)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 20, 0, 60)

    return damage
end

return mobskillObject
