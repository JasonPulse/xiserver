-----------------------------------
-- Trust: Balamor
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

    -- Special (DRK): per FFXIclopedia uses NO job abilities. Only casts Absorb spells
    -- (his unique WS come from his skill list). His auto-attacks deal dark magic damage.
    xi.trust.darkAutoAttacks(mob)
    -- NOTE: retail Balamor is classed undead (cannot be cured; self-heals via Last Laugh).
    -- Intentionally NOT implemented — not worth an engine change for one trust, and making him
    -- undead would let party AoE Cures damage him. Dark auto-attacks above cover the visible part.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ABSORB })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
