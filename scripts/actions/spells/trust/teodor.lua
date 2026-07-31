-----------------------------------
-- Trust: Teodor
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

    mob:addMod(xi.mod.FASTCAST, 30) -- "some level of Fast Cast" (per FFXIclopedia)

    -- Auto-attacks deal dark magic damage (his strong ranged dark attack when kept at range).
    xi.trust.darkAutoAttacks(mob)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL },    { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 180)
    -- NOTE: retail Teodor is classed undead (cannot be cured, only Healing Breath).
    -- Intentionally NOT implemented (not worth an engine change for one trust; would let party
    -- Cures damage him). His Mammet-style ranged dark auto-attack is also not modeled.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },                         { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.THUNDAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.EN_MOB_WEAKNESS, xi.magic.spellFamily.THUNDAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BLIZZAGA })

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
