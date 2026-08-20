-----------------------------------
--  Bane of Tartarus
--  Description: Dispels all positive status effects and inflicts Weakness.
--  Type: Magical
--  Range: Unknown (bg-wiki lists Area/Target as unknown)
-----------------------------------
-- HADES (Second Form). SoA Mission 5-4-1 Abomination, Ra'Kaznar Turris.
-- bg-wiki "Hades (Second Form)" ability table:
--   Class/Type blank | Effect: "Dispels all buffs. Inflicts Weakness."
--   Condition: Wings extended.
--
-- MODELLED ON: leafstorm_dispel.lua, the repo's reference for a full-strip skill --
-- dispelAllStatusEffect with the DISPELABLE|FOOD flags and the DISAPPEAR_NUM
-- message.
-- Unlike the other eleven, bg-wiki lists NO damage for this one, so it deals
-- none -- it is a pure dispel plus Weakness. Weakness is xi.effect.WEAKNESS.
-- Wing-state not gated; see tenbrous_grip.lua.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local count = target:dispelAllStatusEffect(bit.bor(xi.effectFlag.DISPELABLE, xi.effectFlag.FOOD))

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.WEAKNESS, 1, 0, 60)

    if count == 0 then
        skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
    else
        skill:setMsg(xi.msg.basic.DISAPPEAR_NUM)
    end

    return count
end

return mobskillObject
