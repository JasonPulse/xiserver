-----------------------------------
-- Trust: Valaineral
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell)
end

spellObject.onSpellCast = function(caster, target, spell)
    -- Records of Eminence: Alter Ego: Valaineral
    if caster:getEminenceProgress(933) then
        xi.roe.onRecordTrigger(caster, 933)
    end

    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    --[[
        Summon: With your courage and valor, Altana's children will live to see a brighter day.
        Summon (Formerly): Let the Royal Family’s blade be seared forever into their memories!
    ]]
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Base melee damage boost for tank trusts (1.5x)
    mob:addMod(xi.mod.ATT, math.floor(mob:getMainLvl() * 1.5))

    -- Enmity-geared tank: +100 Enmity (engine cap) = 2x hate generation to hold aggro at scale.
    mob:addMod(xi.mod.ENMITY, 100)

    -- Keeps Majesty up (enhanced + AoE cures), then heals.
    mob:addGambit(ai.t.SELF,  { ai.c.NOT_STATUS, xi.effect.MAJESTY }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.MAJESTY })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 },                   { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })

    -- Defensive cooldowns / enmity buffs.
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.SENTINEL })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.FEALTY },   { ai.r.JA, ai.s.SPECIFIC, xi.ja.FEALTY })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PALISADE }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.PALISADE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.DEFENDER }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DEFENDER })

    -- Enmity: Provoke + Divine-Emblem-boosted Flash.
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_HAS_TOP_ENMITY, 0 },              { ai.r.JA, ai.s.SPECIFIC, xi.ja.PROVOKE })
    mob:addGambit(ai.t.SELF,   { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.DIVINE_EMBLEM })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH },         { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH })

    -- MP recovery.
    mob:addGambit(ai.t.SELF, { ai.c.MPP_LT, 50 }, { ai.r.JA, ai.s.SPECIFIC, xi.ja.CHIVALRY })

    -- Protective spells (now in his spell list 322).
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT },  { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
    mob:addGambit(ai.t.SELF,  { ai.c.NOT_STATUS, xi.effect.REPRISAL }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.REPRISAL })
    mob:addGambit(ai.t.SELF,  { ai.c.NOT_STATUS, xi.effect.PHALANX },  { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.PHALANX })
    mob:addGambit(ai.t.SELF,  { ai.c.NOT_STATUS, xi.effect.ENLIGHT },  { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ENLIGHT })
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
