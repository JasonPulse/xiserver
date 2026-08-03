-----------------------------------
-- Trust: Invincible Shield UC
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

    -- WAR/MNK: page JAs are Provoke, Warcry, Retaliation, Tomahawk, Restraint, Blood Rage
    -- (NOT Berserk/Aggressor). WS: Raging Rush / Steel Cyclone / Soturi's Fury.
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_HAS_TOP_ENMITY, 0 },              { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.WARCRY },       { ai.r.JA, ai.s.SPECIFIC, xi.ja.WARCRY })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.RETALIATION },  { ai.r.JA, ai.s.SPECIFIC, xi.ja.RETALIATION })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.RESTRAINT },    { ai.r.JA, ai.s.SPECIFIC, xi.ja.RESTRAINT })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.BLOOD_RAGE },   { ai.r.JA, ai.s.SPECIFIC, xi.ja.BLOOD_RAGE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                          { ai.r.JA, ai.s.SPECIFIC, xi.ja.TOMAHAWK })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
