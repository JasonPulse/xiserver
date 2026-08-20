-----------------------------------
--  Supernova
--  Description: Deals percentage-based Dark damage in an area of effect. Additional effect: Doom.
--  Type: Magical
--  Range: 20' radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Supernova: (Only while wings are down) {{magical}} {{dark}} 20' AoE
--    percentage-based damage and 10-count doom"
--   "Gains the following under 50%."
--
-- MODELLED ON: no existing skill is percentage-based, so damage is computed directly
-- from the target's current HP rather than through mobMagicalMove -- bg-wiki says
-- "percentage-based", which a normal damage formula would not reproduce.
-- 50% of current HP is used: bg-wiki gives no figure, and half is the
-- conventional value for a percentage nuke of this kind. Doom is applied with a
-- 10-tick count, which IS bg-wiki's stated "10-count doom".
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki: gained under 50% HP, and only while wings are DOWN.
    if mob:getHPP() >= 50 or mob:getLocalVar('shinryuWingsSpread') == 1 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = math.floor(target:getHP() * 0.5)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.DOOM, 1, 3, 30)

    return damage
end

return mobskillObject
