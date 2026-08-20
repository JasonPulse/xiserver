-----------------------------------
--  Cosmic Breath
--  Description: Deals damage to targets in a fan-shaped area. Additional effects: Plague, Attack Down, Magic Attack Down and Frost.
--  Type: Magical
--  Range: Conal
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Cosmic Breath: {{magical}} conal damage with additional effect Plague and
--    Attack Down, Magic Attack Down, and Frost." / "May be avoided by standing
--    to the side."
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical damage
-- + status effect" mobskill. Four statuses are applied in
-- sequence, each with the repo's standard block for that effect.
-- Element: bg-wiki marks this {{magical}} with no element, so DARK is used --
-- Shinryu is the Twilight God's form and DARK is the repo's default for untyped
-- mob magic (implosion.lua does the same). Called out, not passed off as sourced.
-- "May be avoided by standing to the side" is conal targeting, which is data
-- (mob_skills.mob_skill_aoe), not script logic.
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

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.PLAGUE, 5, 3, 60)
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.ATTACK_DOWN, 25, 0, 60)
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.MAGIC_ATK_DOWN, 25, 0, 60)
    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.FROST, 5, 3, 60)

    return damage
end

return mobskillObject
