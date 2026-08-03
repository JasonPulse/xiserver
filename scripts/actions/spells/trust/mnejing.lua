-----------------------------------
-- Trust: Mnejing
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

    -- Innate -37.5% Damage Taken trait (per FFXIclopedia). DMG mod is /10000, so -3750.
    mob:addMod(xi.mod.DMG, -3750)

    -- Enmity-geared tank: +100 Enmity (engine cap) = 2x hate generation to hold aggro at scale.
    mob:addMod(xi.mod.ENMITY, 100)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SHIELD_BASH })

    -- Synergy: receives increased Defense and Enmity while Nashmeira is in the party.
    mob:addListener('COMBAT_TICK', 'MNEJING_NASHMEIRA_SYNERGY', function(mobArg)
        local withNashmeira = xi.trust.partyHasAnyTrust(mobArg, { xi.magic.spell.NASHMEIRA, xi.magic.spell.NASHMEIRA_II })
        mobArg:setMod(xi.mod.DEF, withNashmeira and 100 or 0)
        mobArg:setMod(xi.mod.ENMITY, withNashmeira and 130 or 100) -- base 100 + 30 with Nashmeira
    end)

    -- NOTE(registry): Flashbulb + Disruptor automaton mobskills; skill_list has generic sword WS,
    -- not his automaton WS (Chimera Ripper/Slapstick/String Clipper/Shield Subverter).
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
