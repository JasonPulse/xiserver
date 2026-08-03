-----------------------------------
-- Trust: Excenmille S
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.EXCENMILLE)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Special weapon-skill DD (per FFXIclopedia): no job abilities listed; possesses a
    -- form of Regain. WS: Gyre Strike / Orcsbane / Songbird Swoop / Stag's Call / Stag's Charge.
    -- (Removed the wrong Berserk/Aggressor/Warcry template.)
    mob:addMod(xi.mod.REGAIN, 100)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
