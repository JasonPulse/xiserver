-----------------------------------
-- Trust: August
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
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.ARCIELA]   = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.TEODOR]    = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.ROSULATIA] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.MORIMAR]   = xi.trust.messageOffset.TEAMWORK_4,
    })

    mob:setMobSkillAttack(1197)

    -- Base melee damage boost for tank trusts (1.5x)
    mob:addMod(xi.mod.ATT, math.floor(mob:getMainLvl() * 1.5))

    -- Emulate a fully enmity-geared tank: +100 Enmity (engine cap) doubles all
    -- hate generation (Provoke, Flash, Cure, damage) so it holds aggro off player
    -- DPS as levels scale.
    mob:addMod(xi.mod.ENMITY, 100)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    -- Retail kit (FFXIclopedia): JAs Provoke / Sentinel / Divine Emblem;
    -- spells Cure, Flash, Reprisal, Holy II. (The former Shield Bash / Defender /
    -- Palisade / Warcry were a non-retail crutch for weak tanking — the ENMITY mod
    -- above is the real fix, so they're removed.)
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    mob:addGambit(ai.t.SELF, { ai.c.HPP_LT, 50 },                   { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REPRISAL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REPRISAL })

    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                          { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH },         { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })

    -- Holy II as damage/enmity filler (won't break a forming skillchain).
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.HOLY_II })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
