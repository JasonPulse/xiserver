-----------------------------------
-- Trust: Shantotto
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.SHANTOTTO_II)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.teamworkMessage(mob, {
        [xi.magic.spell.AJIDO_MARUJIDO] = xi.trust.messageOffset.TEAMWORK_1,
        [xi.magic.spell.STAR_SIBYL] = xi.trust.messageOffset.TEAMWORK_2,
        [xi.magic.spell.KORU_MORU] = xi.trust.messageOffset.TEAMWORK_3,
        [xi.magic.spell.KING_OF_HEARTS] = xi.trust.messageOffset.TEAMWORK_4
    })

    -- Family lookups use the highest tier the trust has learned. Shantotto's
    -- spellList (308) covers all 6 elements up to tier V; without concrete
    -- family gambits the previous NONE-family entries resolved to no spell.
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 180)
    mob:addGambit(ai.t.SELF,   { ai.c.MPP_LT, 40 },                           { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANA_WALL })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },                      { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.EN_MOB_WEAKNESS, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BLIZZARD })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.WATER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.STONE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.AERO })

    local power = mob:getMainLvl() / 10
    mob:addMod(xi.mod.MATT, power)
    mob:addMod(xi.mod.MACC, power)
    mob:addMod(xi.mod.HASTE_MAGIC, 1000) -- 10% Haste (Magic)

    mob:setAutoAttackEnabled(false)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.CASTER_CAMP)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
