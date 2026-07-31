-----------------------------------
-- Trust: Selh'teus
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

    -- Forced ~95% hit rate regardless of content level (per FFXIclopedia).
    mob:addMod(xi.mod.ACC, 1000)

    -- Weapon skills Revelation / Luminous Lance (in his skill_list 1094).
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    -- Rejuvenation: instantly restores HP/MP/TP to the entire party. Fires when any party
    -- member drops to yellow HP, on a long cooldown (his marquee support ability).
    mob:addGambit(ai.t.SELF, { ai.c.PARTY_HPP_LT, 75 }, { ai.r.MS, ai.s.SPECIFIC, 3622 }, 90)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
