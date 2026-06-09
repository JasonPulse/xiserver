-----------------------------------
-- Wildskeeper Reives
--
-- Retail: 6 Naakual bosses across the SoA continent. Each is summoned by
-- trading a pop key item to the relevant Reive NPC; the resulting fight is
-- a large Reive-style engagement with shared rewards (bayld + drops +
-- progression for the Adoulin storyline).
--
-- Status BEFORE this module: all 6 mob_pools entries (Colkhab, Tchakka,
-- Achuka, Yumcax, Hurkan, Kumhau) exist; all 6 mob_spawn_points exist with
-- proper zone coords; all 6 pop key items exist in scripts/enum/key_item.lua.
-- Missing: any trade/trigger handler that consumes a pop KI and spawns the
-- corresponding boss, and any death handler that grants bayld/reward.
--
-- This module's job:
--   1. xi.wildskeeperReives.popBoss(player, kiId) — consume the pop KI,
--      SpawnMob the corresponding Naakual at its retail coords. Returns
--      (true, label) or (false, reason).
--   2. xi.wildskeeperReives.grantRewards(mob, player) — call from each
--      Naakual's onMobDeath; awards a flat bayld stipend to the entire
--      alliance and bumps a "WKR_<Name>_Defeated" CharVar so progression
--      tracking is available.
--
-- Periodic auto-respawn is intentionally NOT included — WKRs are an
-- on-demand fight, not a rotation. Players use a pop KI per attempt.
-----------------------------------
xi = xi or {}
xi.wildskeeperReives = xi.wildskeeperReives or {}

-- Pop KI → spawn data. Zone IDs match xi.zone.* via the autoloaded enum.
-- mobName is looked up in zones[zoneId].mob at runtime (we don't bake entity
-- ids in case mob_spawn_points get renumbered upstream).
xi.wildskeeperReives.pops =
{
    [xi.ki.BRIER_PROOF_NET]             = { label = 'Colkhab', mobName = 'Colkhab', zoneId = xi.zone.CEIZAK_BATTLEGROUNDS },
    [xi.ki.COMPASS_OF_TRANSFERENCE]     = { label = 'Tchakka', mobName = 'Tchakka', zoneId = xi.zone.FORET_DE_HENNETIEL  },
    [xi.ki.MAGMA_MITIGATION_SET]        = { label = 'Achuka',  mobName = 'Achuka',  zoneId = xi.zone.MORIMAR_BASALT_FIELDS },
    [xi.ki.RESURRECTION_RETARDANT_AXE]  = { label = 'Yumcax',  mobName = 'Yumcax',  zoneId = xi.zone.YORCIA_WEALD          },
    [xi.ki.INSULATOR_TABLET]            = { label = 'Hurkan',  mobName = 'Hurkan',  zoneId = xi.zone.MARJAMI_RAVINE        },
    [xi.ki.ANTI_GLACIATION_GEAR]        = { label = 'Kumhau',  mobName = 'Kumhau',  zoneId = xi.zone.KAMIHR_DRIFTS         },
}

local bayldReward = 5000 -- per alliance member on kill (retail varies; flat for our server)
local rewardRadius = 100 -- yalms; Reive engagements are large

xi.wildskeeperReives.popBoss = function(player, kiId)
    if not player or not kiId then
        return false, 'invalid args'
    end

    local entry = xi.wildskeeperReives.pops[kiId]
    if not entry then
        return false, 'kiId is not a registered Naakual pop item'
    end

    if not player:hasKeyItem(kiId) then
        return false, 'player does not hold the pop key item'
    end

    if player:getZoneID() ~= entry.zoneId then
        return false, string.format('must be in zone %d to pop %s', entry.zoneId, entry.label)
    end

    local zoneIds = zones[entry.zoneId]
    if not zoneIds or not zoneIds.mob then
        return false, string.format('zone %d mob table not initialised', entry.zoneId)
    end

    local mobEntityId = zoneIds.mob[entry.mobName]
    if type(mobEntityId) == 'table' then
        mobEntityId = mobEntityId[1]
    end

    if not mobEntityId then
        return false, string.format('no entity id for %s in zone %d', entry.mobName, entry.zoneId)
    end

    player:delKeyItem(kiId)
    SpawnMob(mobEntityId)
    return true, string.format('Spawned %s.', entry.label)
end

xi.wildskeeperReives.grantRewards = function(mob, player)
    if not mob or not player then
        return
    end

    local mobName     = mob:getName()
    local defeatedVar = string.format('WKR_%s_Defeated', mobName)
    local alliance    = player:getAlliance() or { player }

    for _, member in pairs(alliance) do
        if
            member and
            member:getZoneID() == mob:getZoneID() and
            member:checkDistance(mob) <= rewardRadius
        then
            member:addCurrency('bayld', bayldReward)
            member:setCharVar(defeatedVar, (member:getCharVar(defeatedVar) or 0) + 1)
            member:printToPlayer(string.format('You earn %d bayld for defeating %s.', bayldReward, mobName))
        end
    end
end
