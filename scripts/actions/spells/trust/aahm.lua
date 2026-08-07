-----------------------------------
-- Trust: AAHM
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

    -- NIN/WAR tank: gains TP quickly and weapon skills at 1000 TP regardless of
    -- party TP, with random weapon skill selection (Cross Reaver / Swift Blade / Chant du Cygne).
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)

    -- Casts ninjutsu very fast (per FFXIclopedia): ~80% cast-time reduction via uncapped Fast Cast.
    mob:addMod(xi.mod.UFASTCAST, 80)

    -- Lands hits reliably at content level (also feeds enmity via damage as a tank).
    xi.trust.meleeAccuracyBoost(mob)

    xi.trust.arkAngelSynergy(mob) -- +MDEF while all five Ark Angels are present

    -- Keep shadows up (Utsusemi represented by xi.effect.COPY_IMAGE) and Migawari for survival.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.COPY_IMAGE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.UTSUSEMI })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MIGAWARI },   { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.MIGAWARI_ICHI })

    -- Enfeebling ninjutsu on the target.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.BLINDNESS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.KURAYAMI }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW },      { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HOJO }, 60)

    -- Tank job abilities.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.YONIN },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.YONIN })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.WARCRY }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY })

    mob:addGambit(ai.t.SELF, { ai.c.NOT_HAS_TOP_ENMITY, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
