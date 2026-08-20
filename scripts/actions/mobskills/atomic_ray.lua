-----------------------------------
--  Atomic Ray
--  Description: Deals Fire damage in an area of effect. Additional effect: severe attribute down.
--  Type: Magical
--  Range: Radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Atomic Ray: (Only while wings are spread) {{magical}} {{fire}} AoE damage
--    and -50% to attributes (STR, etc). Prevented with cruor buffs."
--
-- MODELLED ON: great_whirlwind.lua -- the repo's canonical "elemental magical damage
-- + status effect" mobskill.
-- The -50% attribute hit is applied as STR_DOWN with power 50, the same
-- percentage bg-wiki states. The "prevented with cruor buffs" interaction belongs
-- to the Abyssea cruor-buff system, not to this skill, so it is not modelled here.
-- The wings-spread restriction is enforced in onMobSkillCheck via the wing localVar
-- that mighty_guard/the battlefield own -- see cataclysmic_vortex.lua's note.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki: "Only while wings are spread."
    if mob:getLocalVar('shinryuWingsSpread') ~= 1 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 5, xi.element.FIRE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.FIRE, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.FIRE)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.STR_DOWN, 50, 0, 60)

    return damage
end

return mobskillObject
