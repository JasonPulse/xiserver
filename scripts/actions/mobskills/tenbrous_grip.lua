-----------------------------------
--  Tenebrous Grip
--  Description: Deals damage. Additional effect: Blindness. Extends wings.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Damage + Blind. Extends wings."
--   Condition: "Based on remaining HP"
--
-- MODELLED ON: great_whirlwind.lua for damage plus the standard mob Blindness block.
-- Element: bg-wiki leaves Class and Type blank for this ability, so DARK is
-- used -- Hades is a dark-themed Supreme Being and DARK is the repo's default
-- for untyped mob magic (implosion.lua does the same). Called out rather than
-- presented as sourced.
-- NOTE ON "wings": three of this form's abilities (Bane of Tartarus, Crippling
-- Agony, Eternal Misery) are listed by bg-wiki as conditional on "Wings
-- extended", and this skill is what extends them. A localVar is set here so the
-- state is recorded and a future pass can gate those three on it; they are
-- deliberately NOT gated yet, because gating them without a way to retract the
-- wings would make them unusable. The SQL name is tenbrous_grip (a typo in the
-- data); bg-wiki spells it Tenebrous Grip.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.DARK, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BLINDNESS, 20, 0, 60)
    mob:setLocalVar('hadesWingsExtended', 1)

    return damage
end

return mobskillObject
