-----------------------------------
-- Arrogance Incarnate
--
-- Description: Ark Angel EV's version of Spirits Within. Delivers an unavoidable
--              attack whose damage varies with the user's current HP and TP.
-- Type: Magical/Breath
-- Utsusemi/Blink absorb: Ignores shadows and most damage reduction.
-- Range: Melee
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    -- Same HP/TP-scaled formula as Spirits Within.
    local tp  = skill:getTP()
    local hp  = mob:getHP()
    local dmg = math.floor(hp * (math.floor(0.016 * tp) + 16) / 256)
    if tp > 2000 then -- 2001 - 3000
        dmg = math.floor(hp * (math.floor(0.072 * tp) - 96) / 256)
    end

    dmg = math.floor(dmg * 2.5)

    -- Proven to be breath damage.
    dmg = math.floor(dmg * xi.combat.damage.calculateDamageAdjustment(target, false, false, false, true))
    dmg = math.floor(dmg * xi.spells.damage.calculateAbsorption(target, xi.element.NONE, false))
    dmg = math.floor(dmg * xi.spells.damage.calculateNullification(target, xi.element.NONE, false, true))
    dmg = math.floor(target:handleSevereDamage(dmg, false))

    dmg = utils.handlePhalanx(target, dmg)

    if dmg < 0 then
        return 0
    end

    dmg = utils.handleStoneskin(target, dmg)

    if dmg > 0 then
        target:wakeUp()
        target:updateEnmityFromDamage(mob, dmg)
    end

    target:takeDamage(dmg, mob, xi.attackType.BREATH, xi.damageType.ELEMENTAL)
    return dmg
end

return mobskillObject
