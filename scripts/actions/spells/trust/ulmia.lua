-----------------------------------
-- Trust: Ulmia
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

    -- Status removal
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })

    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 },  { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 },  { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 },  { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 },  { ai.r.MA, ai.s.SECOND_HIGHEST, xi.magic.spellFamily.VALOR_MINUET }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_CASTER, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_CASTER, 0 }, { ai.r.MA, ai.s.SECOND_HIGHEST, xi.magic.spellFamily.MAGES_BALLAD }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_CASTER, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.KNIGHTS_MINNE }, 60)
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 40 },          { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.KNIGHTS_MINNE }, 30)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.SONG_ROTATION)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
