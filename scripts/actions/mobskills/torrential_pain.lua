-----------------------------------
--  Torrential Pain
--  Description: Deals Water damage. Additional effect: Dispel.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class Magical | Type Water | Effect: "Damage + Dispel"
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical
-- damage + one status effect" mobskill.
-- Dispel half taken from leafstorm_dispel.lua.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.WATER, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.WATER, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.WATER)

    -- "Damage + Dispel" -- a single strip, unlike Bane of Tartarus below
    -- which bg-wiki describes as dispelling ALL buffs.
    target:dispelStatusEffect()

    return damage
end

return mobskillObject
