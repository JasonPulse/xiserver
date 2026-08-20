-----------------------------------
--  Ceaseless Surge
--  Description: Deals Thunder damage. Additional effect: Stun.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class Magical | Type Thunder | Effect: "Damage + Stun"
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical
-- damage + one status effect" mobskill.
-- Stun 1 / 0 / 5 matches Fulminous Smash on the first form.
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
