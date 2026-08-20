-----------------------------------
--  Mighty Guard
--  Description: Restores the caster's HP and grants a damage-nullifying barrier and Regain.
--  Type: Buff
--  Range: Self
-----------------------------------
-- SHINRYU. The Wyrm God (Abyssea - Empyreal Paradox), skill list 475.
-- bg-wiki "Shinryu", The Wyrm God notes:
--   "Mighty Guard: {{buff}} Recovers ~15% HP, gains a dispellable 100 TP/tick
--    Regain effect, and nullifies any damage that is less than 300."
--   Quest page: "he will gain a large reduction to physical and magical damage."
--
-- MODELLED ON: xi.mobskills.mobBuffMove for the self-buff, plus a direct addHP for the
-- heal. xi.effect.MIGHTY_GUARD already exists in the effect enum, so the barrier
-- uses its own effect rather than borrowing MAGIC_SHIELD/PHYSICAL_SHIELD.
-- Heal is 15% of max HP and Regain power is 100 per tick -- both figures come
-- straight from bg-wiki. The "nullifies damage under 300" threshold is carried as
-- the MIGHTY_GUARD effect's power so the damage path can read it; enforcing the
-- nullification itself is a combat-layer concern, not something a mobskill can do.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    local healed = math.floor(mob:getMaxHP() * 0.15)

    mob:addHP(healed)
    mob:addStatusEffect(xi.effect.MIGHTY_GUARD, 300, 0, 180)
    mob:addStatusEffect(xi.effect.REGAIN, 100, 3, 180)

    skill:setMsg(xi.msg.basic.SKILL_MISS)

    return xi.effect.MIGHTY_GUARD
end

return mobskillObject
