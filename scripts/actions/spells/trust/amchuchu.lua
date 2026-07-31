-----------------------------------
-- Trust: Amchuchu
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

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SWORDPLAY }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SWORDPLAY })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.VALLATION }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.VALLATION })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.VALIANCE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.VALIANCE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.EMBOLDEN }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.EMBOLDEN })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    -- Applies elemental runes (strong vs the current day); stacks up to 3.
    mob:addGambit(ai.t.SELF, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.RUNE_ENCHANTMENT })

    -- Designated SATA tank: holds the line between master and mob, so a THF
    -- master can Trick Attack through her from anywhere. Provoke keeps the
    -- transferred hate where it belongs.
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.TA_ANCHOR)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
