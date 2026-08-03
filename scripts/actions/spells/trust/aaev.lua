-----------------------------------
-- Trust: AAEV
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

    -- Base melee damage boost for tank trusts (1.5x)
    mob:addMod(xi.mod.ATT, math.floor(mob:getMainLvl() * 1.5))

    -- Emulate a fully enmity-geared tank: +100 Enmity (engine cap) doubles all
    -- hate generation (Provoke, Flash, Cure, damage) so it holds aggro off player
    -- DPS as levels scale.
    mob:addMod(xi.mod.ENMITY, 100)

    -- High Cure Potency (~+50%) job trait per FFXIclopedia.
    mob:addMod(xi.mod.CURE_POTENCY, 50)

    xi.trust.arkAngelSynergy(mob) -- +MDEF while all five Ark Angels are present

    -- PLD/WHM tank: weapon skills at 1000 TP
    -- (Arrogance Incarnate / Vorpal Blade / Dominion Slash / Chant du Cygne).
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)

    -- Healing.
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Defensive cooldowns and self-buffs.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PALISADE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PALISADE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REPRISAL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REPRISAL })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PHALANX },  { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ENLIGHT },  { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ENLIGHT })

    -- Enmity: Divine Emblem then Flash (Flash is favoured over Holy while Divine Emblem is up).
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH },         { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })

    -- MP recovery.
    mob:addGambit(ai.t.SELF, { ai.c.MPP_LT, 50 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHIVALRY })

    -- Holy as damage/enmity filler (won't break a forming skillchain).
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HOLY })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
