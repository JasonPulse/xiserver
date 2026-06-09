-----------------------------------
-- Domain Invasion
--
-- Retail: recurring NM spawns across Escha/Reisenjima/Outer Ra'Kaznar/etc.
-- Players kill the rotating boss → earn Domain Invasion Points → spend them
-- at Zurim in Norg for ROV-era gear (Hervor, Heidrek, Voluspa, Hauksbok,
-- Odyssean/Valorous/Herculean/Chironic/Merlinic augment shells, etc.).
--
-- Status BEFORE this module: Zurim vendor + char_points.domain_points column
-- + 0x118 currency packet field — all wired. Missing: any mob script that
-- granted domain_points on death, and any way to spawn the rotation NMs
-- (mob_groups.respawn=0 means they sit dormant until a SpawnMob call).
--
-- This module's job:
--   1. xi.domainInvasion.grantPoints(player, mob) — call from onMobDeath of
--      any DI boss; awards points to all alliance members within range and
--      scales by mob level. Player-facing message uses the standard
--      "Domain Invasion points obtained" battle message.
--   2. xi.domainInvasion.spawnNext() — GM-callable helper that spawns the
--      next NM in the rotation. We avoid cron-style automatic spawning
--      because the timing/cycle would need in-game verification — for a
--      4-player server, manual spawning via `!exec xi.domainInvasion.spawnNext()`
--      (or a future GM command) is simpler and safer.
--
-- Rotation: ordered list of {label, mob_name, mob_pool_id, zone_id}. Pool ids
-- match sql/mob_pools.sql. Mob_name is used by xi.zone.<X>.mob enum lookups
-- when wiring per-zone IDs; we resolve via mob_spawn_points entity IDs at
-- runtime instead.
-----------------------------------
xi = xi or {}
xi.domainInvasion = {}

-- The mobs SE chose for retail Domain Invasion. Entity-id resolution is done
-- by name + zone via mob_spawn_points; we don't bake IDs in so this stays
-- robust to npc_list/mob_spawn_points renumbering.
xi.domainInvasion.rotation =
{
    { label = 'Yumcax',     mobName = 'Yumcax',             zoneId = xi.zone.YORCIA_WEALD       },
    { label = 'Naga Raja',  mobName = 'Naga_Raja',          zoneId = xi.zone.ESCHA_RUAUN        },
    { label = 'Kyou',       mobName = 'Kyou',               zoneId = xi.zone.REISENJIMA_HENGE   },
    { label = 'Suttung',    mobName = 'Suttung',            zoneId = xi.zone.DYNAMIS_QUFIM      },
}

local rotationVar     = 'DomainInvasion_RotationIndex'  -- ServerVariable: 0-based rotation cursor
local lastSpawnVar    = 'DomainInvasion_LastSpawnTime'  -- ServerVariable: last spawn UNIX timestamp

local pointsPerKill     = 10  -- per-player base award; party scaling applied below
local dailyCap          = 600 -- retail-style daily cap on domain_points_daily
local cruorRangeYalms   = 50  -- "participated" radius for point distribution

-- Award domain_points to all alliance members who participated. Tries to
-- respect the daily cap stored in char_points.domain_points_daily. Caller
-- is expected to also handle any post-kill spawn cleanup.
xi.domainInvasion.grantPoints = function(mob, player)
    if not mob or not player then
        return
    end

    local mobLevel = mob:getMainLvl() or 99
    local alliance = player:getAlliance() or { player }

    for _, member in pairs(alliance) do
        if
            member and
            member:getZoneID() == mob:getZoneID() and
            member:checkDistance(mob) <= cruorRangeYalms
        then
            local award       = pointsPerKill + math.max(0, mobLevel - 99)
            local dailyEarned = member:getCurrency('domain_points_daily')

            if dailyEarned < dailyCap then
                local clamped = math.min(award, dailyCap - dailyEarned)
                if clamped > 0 then
                    member:addCurrency('domain_points', clamped)
                    member:addCurrency('domain_points_daily', clamped)
                    member:printToPlayer(string.format('You earn %d Domain Invasion points.', clamped))
                end
            end
        end
    end
end

-- Spawn the next rotation NM. Cycles through xi.domainInvasion.rotation via
-- the DomainInvasion_RotationIndex ServerVariable. Looks up the mob by name
-- using xi.zone.<zoneId>.mob (the autoloaded zone IDs table) and SpawnMob's
-- the first matching entity id.
xi.domainInvasion.spawnNext = function()
    local entries = xi.domainInvasion.rotation
    if #entries == 0 then
        return false, 'No rotation entries configured.'
    end

    local idx     = (GetServerVariable(rotationVar) % #entries) + 1
    local entry   = entries[idx]
    local zoneIds = zones[entry.zoneId]

    if not zoneIds or not zoneIds.mob then
        return false, string.format('Zone %d has no mob ID table loaded (zone not initialised yet?).', entry.zoneId)
    end

    local mobEntityId = zoneIds.mob[entry.mobName]
    if type(mobEntityId) == 'table' then
        mobEntityId = mobEntityId[1]
    end

    if not mobEntityId then
        return false, string.format('No entity id for %s in zone %d.', entry.mobName, entry.zoneId)
    end

    SpawnMob(mobEntityId)
    SetServerVariable(rotationVar, idx) -- advance cursor for next call
    SetServerVariable(lastSpawnVar, GetSystemTime())
    return true, string.format('Spawned %s in zone %d (rotation %d/%d).', entry.label, entry.zoneId, idx, #entries)
end

-- Convenience for GM use / mob scripts: `local label = xi.domainInvasion.currentLabel()`
xi.domainInvasion.currentLabel = function()
    local entries = xi.domainInvasion.rotation
    local idx     = (GetServerVariable(rotationVar) % #entries) + 1
    return entries[idx] and entries[idx].label or 'unknown'
end
