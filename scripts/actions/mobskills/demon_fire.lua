-----------------------------------
--  Demonfire
--  Description: Deals Fire damage. Additional effect: Burn.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class Magical | Type Fire | Effect: "Damage + Burn"
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical
-- damage + one status effect" mobskill.
-- Burn values match Flaming Kick on the first form, which bg-wiki also lists
-- as fire Damage + Burn. Note the SQL name is demon_fire; bg-wiki spells it
-- Demonfire.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.FIRE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.FIRE, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.FIRE)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BURN, 3, 3, 90)

    return damage
end

return mobskillObject
