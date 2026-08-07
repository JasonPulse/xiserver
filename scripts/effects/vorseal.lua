-----------------------------------
-- xi.effect.VORSEAL
-- Aggregate of all permanently purchased vorseal lines (see
-- xi.eschanHub.vorsealLines). Mods are computed from the player's
-- Vorseal_<KEY> CharVars: each line contributes its per-tier mod steps
-- times the owned tier.
--
-- INVARIANT: the CharVars must not change while the effect is active —
-- purchases remove the effect first, bump the tier, then re-apply
-- (eschan_hub.lua onSageTrade). Otherwise gain/lose would go asymmetric.
-----------------------------------
require('scripts/globals/eschan_hub')
-----------------------------------
---@type TEffect
local effectObject = {}

local eachOwnedMod = function(target, fn)
    for _, line in ipairs(xi.eschanHub.vorsealLines) do
        local tier = target:getCharVar('Vorseal_' .. line.key)
        if tier > 0 then
            for _, m in ipairs(line.mods) do
                fn(m[1], m[2] * tier)
            end
        end
    end
end

effectObject.onEffectGain = function(target, effect)
    -- Vorseals are a zone aura: their bonuses only apply inside the Eschan
    -- zones / Reisenjima, where applyVorseals re-adds this on zone-in. Flag
    -- it ON_ZONE so the core strips it the moment the player zones out (it
    -- re-applies on the next Eschan zone-in). This replaces the effect's
    -- default DB flag so it does NOT also drop on death/KO.
    effect:setEffectFlags(xi.effectFlag.ON_ZONE)

    eachOwnedMod(target, function(mod, value)
        target:addMod(mod, value)
    end)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
    eachOwnedMod(target, function(mod, value)
        target:delMod(mod, value)
    end)
end

return effectObject
