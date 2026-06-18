-----------------------------------
-- Area: Walk of Echoes
--  Mob: Lady Lilith (WotG Mission 51: Maiden of the Dusk, phase 1)
-- Spawn point 17523185 at (-700, -13.27, -140, 64). Group 56 → pool 2316
-- (family 473 Lady_Lilith, lv81-82). HP 9800 (per bg-wiki) set in
-- mob_groups via this session's update — see migration 053.
-- On death, transitions to phase 2 (Lilith_Ascendant) — handled via the
-- existing mob_groups setup; mission progression handled in the WotG 51
-- mission script's onMobDeath for Lilith_Ascendant (final form).
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    -- Phase 1 death: phase 2 (Lilith_Ascendant) spawns from her own spawn
    -- point (17523186, group 57). Mission completion fires on her death,
    -- not Lady_Lilith's — see scripts/missions/wotg/51_Maiden_of_the_Dusk.lua.
end

return entity
