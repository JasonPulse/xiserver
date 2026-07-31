-----------------------------------
-- Trust: Luzaf
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

    -- COR damage dealer (per FFXIclopedia): Triple Shot + Quick Draw, no Phantom Roll.
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.TRIPLE_SHOT },     { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRIPLE_SHOT })
    -- Dark Shot to remove an enhancement when the target is buffed.
    mob:addGambit(ai.t.TARGET, { ai.c.STATUS_FLAG, xi.effectFlag.DISPELABLE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DARK_SHOT })
    -- Quick Draw: fire the elemental shot the target is weakest to (shares Quick Draw recast).
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.JA, ai.s.QD_WEAKNESS, 0 })
    -- Fires his gun between shots.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.RATTACK, 0, 0 }, 10)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
