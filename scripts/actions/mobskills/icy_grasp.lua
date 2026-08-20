-----------------------------------
--  Icy Grasp
--  Description: Deals Ice damage to targets in a fan-shaped area. Additional effect: Paralysis and Terror.
--  Type: Magical
--  Range: Conal
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area Conal | Target Player | Class magical | Type ice
--   Effect: "Damage, Paralysis, and Terror" | Condition HP<75%
--
-- MODELLED ON: great_whirlwind.lua for the damage, plus the standard Paralysis and
-- Terror mobStatusEffectMove pairs used across the repo.
-- Paralyze 20 / 0 / 60 is the common mob Paralyze block; Terror is applied with
-- power 1 for 5s, the usual short mob Terror. bg-wiki gives no durations.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki Condition: HP<75%.
    if mob:getHPP() >= 75 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.ICE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.ICE, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.ICE)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PARALYSIS, 20, 0, 60)
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, 5)

    return damage
end

return mobskillObject
