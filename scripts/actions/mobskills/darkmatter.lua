-----------------------------------
--  Dark Matter
--  Description: Deals Dark damage in an area of effect. Additional effect: Terror.
--  Type: Magical
--  Range: 20' radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Dark Matter: {{magical}} {{dark}} 20' AoE damage and Terror (15 seconds+)"
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical damage
-- + status effect" mobskill.
-- Terror duration is 15s, the one figure bg-wiki gives ("15 seconds+").
-- The SQL name is `darkmatter`; bg-wiki spells it Dark Matter.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 5, xi.element.DARK, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.TERROR, 1, 0, 15)

    return damage
end

return mobskillObject
