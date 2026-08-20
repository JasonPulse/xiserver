-----------------------------------
--  Flashflood
--  Description: Deals Water damage in an area of effect. Additional effect: Dispels multiple enhancements.
--  Type: Magical
--  Range: 10' radial
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area AoE 10' | Target Monster | Class magical | Type water
--   Effect: "Damage and Dispels multiple enhancements" | Condition HP<50%
--
-- MODELLED ON: leafstorm_dispel.lua for the dispel half (that file is the repo's
-- reference for a damaging skill that also strips buffs) and great_whirlwind.lua
-- for the elemental damage half.
-- "Multiple" is implemented as two dispelStatusEffect() calls rather than
-- leafstorm's dispelAllStatusEffect(), because bg-wiki distinguishes this from
-- Vivisection's "full Dispel" below -- see that file.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki Condition: HP<50%.
    if mob:getHPP() >= 50 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.WATER, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.WATER, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.WATER)

    -- Two strips = "multiple", as distinct from Vivisection's full dispel.
    target:dispelStatusEffect()
    target:dispelStatusEffect()

    return damage
end

return mobskillObject
