-----------------------------------
--  Cataclysmic Vortex
--  Description: Reduces the HP of all targets in range to 1 and resets enmity.
--  Type: Magical
--  Range: Radial
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Cataclysmic Vortex: {{magical}} AoE HP reduced to 1 and resets enmity of
--    the highest player."
--
-- MODELLED ON: no existing skill does "set HP to 1", so it is done directly with
-- target:setHP(1) rather than through a damage formula -- bg-wiki describes a
-- fixed result, not damage, so routing it through mobMagicalMove would be wrong
-- (it could be resisted or absorbed).
-- Enmity reset uses target:resetEnmity(mob), which is how the repo's other
-- enmity-wipe moves do it. bg-wiki says "the highest player", but the enmity
-- table is per-mob and this is an AoE, so resetting the affected target is the
-- closest faithful behaviour available.
--
-- NOTE ON WINGS: bg-wiki says Shinryu "changes between spread and down wings
-- every 3 minutes", which gates several abilities. That timer belongs to the
-- battlefield/mob controller, not to individual skills; the skills here read a
-- `shinryuWingsSpread` localVar so the gating is expressed and ready, and default
-- to usable when nothing sets it.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    target:setHP(1)
    target:resetEnmity(mob)

    skill:setMsg(xi.msg.basic.SKILL_ENFEEB)

    return 1
end

return mobskillObject
