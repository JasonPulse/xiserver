-----------------------------------
-- Trust: Joachim
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Joachim
    if caster:getEminenceProgress(937) then
        xi.roe.onRecordTrigger(caster, 937)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Status removal (highest priority)
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.POISON }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.POISONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PARALYNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLINDNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.PETRIFICATION }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STONA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.DISEASE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.VIRUNA })
    mob:addGambit(ai.t.PARTY, { ai.c.STATUS, xi.effect.CURSE_I }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.CURSNA })

    -- Phase-gated song rotation. Gambits fire purely on retry_delay and the
    -- current SONG_ROTATION phase (not NOT_STATUS) so Joachim ignores the 2-song
    -- cap on his own status and pushes 4 distinct songs into the cluster he's
    -- standing in. Songs have 10' AoE so positioning decides who gets what:
    --   Melee phase: March + Madrigal → melee cluster (attack speed + accuracy)
    --   Caster phase: Ballad HIGHEST + SECOND_HIGHEST → stacked MP regen
    -- HIGHEST/SECOND_HIGHEST resolve to whatever tiers Joachim has unlocked at
    -- his current level (below 55 only Ballad I exists, SECOND_HIGHEST gambit
    -- simply no-ops). 60s retry syncs with the 60s full phase cycle.
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_MELEE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_CASTER, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD }, 60)
    mob:addGambit(ai.t.SELF, { ai.c.SONG_PHASE_CASTER, 0 }, { ai.r.MA, ai.s.SECOND_HIGHEST, xi.magic.spellFamily.MAGES_BALLAD }, 60)

    -- Elegy is a debuff on mob, does not count toward 2-song limit
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.ELEGY }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ELEGY }, 120)

    -- Paeon when party HP is critical
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 40 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ARMYS_PAEON }, 120)

    -- Cures and ranged attacks between songs
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 }, 60)

    mob:setAutoAttackEnabled(false)

    -- SONG_ROTATION: alternates between melee range and caster range every 30s
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.SONG_ROTATION)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
