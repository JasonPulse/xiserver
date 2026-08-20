-----------------------------------
--  Shinryu Attack Right
--  Description: Right-claw strike.
--  Type: Physical
--  Range: Melee
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   Quest page, The Wyrm God: "His regular melee attacks are considered
--    weaponskills, keep this in mind..." -- these seven entries in skill list 475
--    are those attacks, which is why they are plain single-target physical hits
--    rather than named abilities with effects.
--
-- MODELLED ON: the standard single-hit physical mobskill shape (mobPhysicalMove +
-- mobFinalAdjustments + takeDamage), which is what every basic claw/tail
-- weaponskill in the repo uses.
-- No damage multiplier is invented: ftp 1 with a single hit is the plainest
-- physical weaponskill the helper supports, leaving scaling to the mob's own
-- attack stats from mob_pools 3604.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local damage = xi.mobskills.mobPhysicalMove(mob, target, skill, 1, 1, 1, xi.mobskills.physicalTpBonus.NO_EFFECT, 1, 1, 1)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.PHYSICAL, xi.damageType.SLASHING, xi.mobskills.shadowBehavior.NUMSHADOWS_1)

    target:takeDamage(damage, mob, xi.attackType.PHYSICAL, xi.damageType.SLASHING)

    return damage
end

return mobskillObject
