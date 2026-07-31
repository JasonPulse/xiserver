-----------------------------------
-- Trust: D Shantotto
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

    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.ELEMENTAL_SEAL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.ELEMENTAL_SEAL }, 180)
    mob:addGambit(ai.t.SELF,   { ai.c.MPP_LT, 40 },                           { ai.r.JA, ai.s.SPECIFIC, xi.ja.MANA_WALL })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 },                      { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.EN_MOB_WEAKNESS, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.THUNDER })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FIRE })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BLIZZARD })
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 },                            { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.WATER })
    -- Page: "Fights in melee range if possible" (has WS Shadow of Death / Guillotine /
    -- Cross Reaper / Salvation Scythe), so she melees rather than camping.
    -- TODO: "if she has enough threat to be a melee target, she will NOT cast" (enmity gate).
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
