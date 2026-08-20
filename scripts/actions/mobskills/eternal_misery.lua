-----------------------------------
--  Eternal Misery
--  Description: Deals damage. Additional effect: Curse.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Damage + Curse (Recovery) ~5s" | Condition: Wings extended.
--
-- MODELLED ON: impudence.lua, its sibling in this same skill list -- bg-wiki gives
-- both the same "Curse (Recovery)" effect.
-- Element: bg-wiki leaves Class and Type blank for this ability, so DARK is
-- used -- Hades is a dark-themed Supreme Being and DARK is the repo's default
-- for untyped mob magic (implosion.lua does the same). Called out rather than
-- presented as sourced.
-- Duration is 5s here, which is the one number bg-wiki does give ("~5s").
-- The "Wings extended" condition is set by Tenebrous Grip; it is NOT gated here
-- because no wing-state flag exists yet -- see tenbrous_grip.lua.
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

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.CURSE_II, 1, 0, 5)

    return damage
end

return mobskillObject
