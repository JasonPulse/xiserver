-----------------------------------
-- Trust: AAMR
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

    -- BST/THF damage dealer: weapon skills at 1000 TP
    -- (Rampage / Calamity / Havoc Spiral / Cloudsplitter).
    mob:addMod(xi.mod.BEAST_KILLER, 5) -- Beast Killer job trait (per FFXIclopedia)

    -- Lands hits reliably at content level.
    xi.trust.meleeAccuracyBoost(mob)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    xi.trust.arkAngelSynergy(mob) -- +MDEF while all five Ark Angels are present

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SNEAK_ATTACK })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.TRICK_ATTACK })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
