-----------------------------------
--  Flaming Kick
--  Description: Deals Fire damage to targets in a fan-shaped area. Additional effect: Burn.
--  Type: Magical
--  Range: Conal
-----------------------------------
-- HADES (First Form). SoA Mission 5-4 Reckoning, Ra'Kaznar Turris.
-- bg-wiki "Hades (First Form)" ability table:
--   Area Conal | Target Player | Class magical | Type fire
--   Effect: "Damage and Burn." | no HP condition
--
-- MODELLED ON: great_whirlwind.lua (conal magical damage + a damage-over-time status).
-- Burn power/tick/duration copied from that file's Choke values (3 / 3 / 90),
-- since bg-wiki states no numbers and Burn and Choke are the same DoT family.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getMainLvl() * 4, xi.element.FIRE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.FIRE, xi.mobskills.shadowBehavior.IGNORE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.FIRE)

    xi.mobskills.mobStatusEffectMove(mob, target, xi.effect.BURN, 3, 3, 90)

    return damage
end

return mobskillObject
