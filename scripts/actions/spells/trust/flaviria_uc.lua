-----------------------------------
-- Trust: Flaviria UC
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

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.BERSERK }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.BERSERK })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                    { ai.r.JA, ai.s.SPECIFIC, xi.ja.ANGON })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },                    { ai.r.JA, ai.s.SPECIFIC, xi.ja.JUMP })
    mob:addGambit(ai.t.SELF,   { ai.c.ALWAYS, 0 },                    { ai.r.JA, ai.s.SPECIFIC, xi.ja.HIGH_JUMP })
    -- Sheds hate with Super Jump if she pulls the enemy off the tank.
    mob:addGambit(ai.t.SELF,   { ai.c.HAS_TOP_ENMITY, 0 },            { ai.r.JA, ai.s.SPECIFIC, xi.ja.SUPER_JUMP })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
