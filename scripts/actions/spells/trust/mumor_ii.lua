-----------------------------------
-- Trust: Mumor II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL },    { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 180)
    mob:addGambit(ai.t.TARGET, { ai.c.TARGET_READYING, 0 },                      { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },                         { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.EN_MOB_WEAKNESS, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRE })

    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.CASTER_CAMP)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
