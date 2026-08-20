-----------------------------------
--  Vivisection
--  Description: Deals damage in an area of effect. Additional effect: Dispels all positive status effects.
--  Type: Magical
--  Range: Radial
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area AoE | Target Monster | Class magical | Type (none given)
--   Effect: "Damage and full Dispel" | Condition "Very low HP. Can use once."
--
-- MODELLED ON: leafstorm_dispel.lua, which is exactly "damage + dispelAllStatusEffect".
-- Element: bg-wiki leaves Type blank, so DARK is used -- Hades is a Supreme
-- Being/dark-themed NM and DARK is the repo's default for untyped mob magic
-- (implosion.lua does the same). Flagged rather than presented as sourced.
-- "Can use once" is enforced with a localVar rather than a timer.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    -- bg-wiki: "Very low HP. Can use once."
    if mob:getHPP() >= 10 or mob:getLocalVar('vivisectionUsed') == 1 then
        return 1
    end

    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    mob:setLocalVar('vivisectionUsed', 1)

    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.DARK, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.DARK)

    local count = target:dispelAllStatusEffect(bit.bor(xi.effectFlag.DISPELABLE, xi.effectFlag.FOOD))

    if count > 0 then
        skill:setMsg(xi.msg.basic.DISAPPEAR_NUM)
    end

    return damage
end

return mobskillObject
