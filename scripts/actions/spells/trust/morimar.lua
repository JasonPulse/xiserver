-----------------------------------
-- Trust: Morimar
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

    -- Weapon skills at 1000 TP: 12 Blades of Remorse (AoE physical, Light skillchain).
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    -- Vehement Resolution: below 50% HP, fully heals himself, wipes his debuffs, and gains
    -- a Regen aura. Long cooldown so it's an emergency move.
    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT, 50 }, { ai.r.MS, ai.s.SPECIFIC, 3676 }, 120)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
