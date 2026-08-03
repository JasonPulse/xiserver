-----------------------------------
-- Trust: Gadalar
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

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.BLAZE_SPIKES },      { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.BLAZE_SPIKES }, 240)
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },                         { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.FIRAGA })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                               { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRAGA })
    -- Page: runs into melee range to use his scythe (Spinning/Vorpal Scythe, Spiral Hell,
    -- Salamander Flame), so he melees rather than camping like other BLM trusts.
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
