-----------------------------------
--  Eroding Flesh
--  Description: Deals Earth damage in an area of effect. Additional effect: Slow.
--  Type: Magical
--  Range: 10' radial
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area AoE 10' | Target Monster | Class magical | Type earth
--   Effect: "Damage and Slow" | Condition HP<25%
--
-- MODELLED ON: leafstorm_dispel.lua's Slow block (power 2500, tick 0, duration 120)
-- combined with great_whirlwind.lua's elemental damage.
-- 2500 is the repo's standard mob Slow power; bg-wiki gives no value.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki Condition: HP<25%.
    if mob:getHPP() >= 25 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.EARTH, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.EARTH, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.EARTH)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.SLOW, 2500, 0, 120)

    return damage
end

return mobskillObject
