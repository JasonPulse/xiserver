-----------------------------------
--  Ensepulcher
--  Description: Deals Earth damage. Additional effect: Petrification.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class Magical | Type Earth | Effect: "Damage + Petrification"
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical
-- damage + one status effect" mobskill.
-- Petrification power 1 / duration 30 is the common mob Petrify block.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.EARTH, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.EARTH, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.EARTH)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PETRIFICATION, 1, 0, 30)

    return damage
end

return mobskillObject
