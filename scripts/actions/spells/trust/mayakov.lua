-----------------------------------
-- Trust: Mayakov
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

    -- Offensive DNC (per FFXIclopedia): Saber Dance, Drain/Haste Samba, Climactic Flourish,
    -- Feather Step. Does NOT use Curing Waltz.
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.SABER_DANCE },       { ai.r.JA, ai.s.SPECIFIC, xi.ja.SABER_DANCE })
    mob:addGambit(ai.t.SELF,   { ai.c.NO_SAMBA, 0 },                             { ai.r.JA, ai.s.BEST_SAMBA, xi.ja.DRAIN_SAMBA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEATHER_STEP })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.CLIMACTIC_FLOURISH }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CLIMACTIC_FLOURISH })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
