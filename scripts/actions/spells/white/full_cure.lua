-----------------------------------
-- Spell: Full Cure
-- Restores target to full HP and removes several detrimental status effects.
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local missing = target:getMaxHP() - target:getHP()
    target:addHP(missing)

    target:delStatusEffect(xi.effect.WEAKNESS)
    target:delStatusEffect(xi.effect.BLINDNESS)
    target:delStatusEffect(xi.effect.CURSE_I)
    target:delStatusEffect(xi.effect.CURSE_II)
    target:delStatusEffect(xi.effect.DISEASE)
    target:delStatusEffect(xi.effect.PLAGUE)
    target:delStatusEffect(xi.effect.PARALYSIS)
    target:delStatusEffect(xi.effect.PETRIFICATION)
    target:delStatusEffect(xi.effect.POISON)
    target:delStatusEffect(xi.effect.SILENCE)
    target:delStatusEffect(xi.effect.SLOW)
    target:delStatusEffect(xi.effect.MAX_HP_DOWN)
    target:delStatusEffect(xi.effect.MAX_MP_DOWN)

    spell:setMsg(xi.msg.basic.MAGIC_RECOVERS_HP)

    return missing
end

return spellObject
