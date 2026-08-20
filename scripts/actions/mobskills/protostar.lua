-----------------------------------
--  Protostar
--  Description: Deals damage in an area of effect and resets the caster's unused ability timers.
--  Type: Magical
--  Range: 20' radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Protostar: (Only while wings are spread) {{magical}} 20' AoE damage and all
--    unused abilities will have timers reset."
--   "Gains the following under 50%."
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical damage
-- + status effect" mobskill.
-- Element: bg-wiki marks this {{magical}} with no element, so DARK is used --
-- Shinryu is the Twilight God's form and DARK is the repo's default for untyped
-- mob magic (implosion.lua does the same). Called out, not passed off as sourced.
-- The ability-timer reset is a mob-controller behaviour (recast state lives
-- outside the skill), so it is not attempted here rather than faked.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki: gained under 50% HP, and only while wings are spread.
    if mob:getHPP() >= 50 or mob:getLocalVar('shinryuWingsSpread') ~= 1 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 5, xi.element.DARK, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    return damage
end

return mobskillObject
