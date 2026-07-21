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
require('scripts/globals/unity')
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
local accoladeReward    = 10  -- Unity Wanted-NM bonus per kill
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

            xi.unity.grantWantedAccolades(member, accoladeReward)
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

-- Auto-rotation hook. Call from each DI zone's Zone.lua onZoneIn (or any
-- zone that should trigger checks); if no spawn has happened in the last
-- `rotationIntervalSeconds`, fires spawnNext(). Multiple concurrent calls
-- rate-limit naturally via the lastSpawn ServerVariable update inside
-- spawnNext().
local rotationIntervalSeconds = 4 * 60 * 60 -- 4 hours, retail-ish

xi.domainInvasion.checkRotation = function()
    local lastSpawn = GetServerVariable(lastSpawnVar)
    local now       = GetSystemTime()
    if now - lastSpawn < rotationIntervalSeconds then
        return false
    end

    local ok, _ = xi.domainInvasion.spawnNext()
    return ok
end

-- Page labels for the reward stock below (used by the in-zone Register of
-- Deeds catalogs; Zurim in Norg drives the same table through his client
-- menu event).
xi.domainInvasion.rewardStockPages =
{
    [1]  = 'Consumables (10 DP)',
    [2]  = 'Domain Invasion armor (40 DP)',
    [3]  = 'Voluspa weapons and ammo (80 DP)',
    [4]  = 'Accessories (100 DP)',
    [5]  = "Ru'Aun Geas Fete weapons (200 DP)",
    [6]  = "Ru'Aun abjurations (400 DP)",
    [7]  = 'Skill earrings (600 DP)',
    [8]  = 'Reisenjima Geas Fete gear (800 DP)',
    [9]  = 'Hauksbok and accessories (1000 DP)',
    [10] = 'Wyrm Ash (1200 DP)',
}

xi.domainInvasion.rewardStock =
{
    [1] = -- initial page
    {
        [1] = -- subpage
        {
            [1] = { item = xi.item.ESCHALIXIR_P2, cost = 10 },
            [2] = { item = xi.item.FRAYED_SACK_OF_FECUNDITY, cost = 10 },
            [3] = { item = xi.item.FRAYED_SACK_OF_PLENTY, cost = 10 },
            [4] = { item = xi.item.FRAYED_SACK_OF_OPULENCE, cost = 10 },
        },
    },
    [2] =
    {
        [1] =
        {
            [1] = { item = xi.item.HERVOR_GALEA, cost = 40 },
            [2] = { item = xi.item.HERVOR_HAUBERT, cost = 40 },
            [3] = { item = xi.item.HERVOR_MOUFFLES, cost = 40 },
            [4] = { item = xi.item.HERVOR_BRAYETTES, cost = 40 },
            [5] = { item = xi.item.HERVOR_SOLLERETS, cost = 40 },
            [6] = { item = xi.item.HEIDREK_MASK, cost = 40 },
            [7] = { item = xi.item.HEIDREK_HARNESS, cost = 40 },
            [8] = { item = xi.item.HEIDREK_GLOVES, cost = 40 },
            [9] = { item = xi.item.HEIDREK_BRAIS, cost = 40 },
            [10] = { item = xi.item.HEIDREK_BOOTS, cost = 40 },
            [11] = { item = xi.item.ANGANTYR_BERET, cost = 40 },
            [12] = { item = xi.item.ANGANTYR_ROBE, cost = 40 },
            [13] = { item = xi.item.ANGANTYR_MITTENS, cost = 40 },
            [14] = { item = xi.item.ANGANTYR_TIGHTS, cost = 40 },
            [15] = { item = xi.item.ANGANTYR_BOOTS, cost = 40 },
        },
    },
    [3] =
    {
        [1] =
        {
            [1] = { item = xi.item.PAIR_OF_VOLUSPA_KNUCKLES, cost = 80 },
            [2] = { item = xi.item.VOLUSPA_KNIFE, cost = 80 },
            [3] = { item = xi.item.VOLUSPA_SWORD, cost = 80 },
            [4] = { item = xi.item.VOLUSPA_BLADE, cost = 80 },
            [5] = { item = xi.item.VOLUSPA_AXE, cost = 80 },
            [6] = { item = xi.item.VOLUSPA_CHOPPER, cost = 80 },
            [7] = { item = xi.item.VOLUSPA_SCYTHE, cost = 80 },
            [8] = { item = xi.item.VOLUSPA_LANCE, cost = 80 },
            [9] = { item = xi.item.VOLUSPA_KATANA, cost = 80 },
            [10] = { item = xi.item.VOLUSPA_TACHI, cost = 80 },
            [11] = { item = xi.item.VOLUSPA_HAMMER, cost = 80 },
            [12] = { item = xi.item.VOLUSPA_POLE, cost = 80 },
            [13] = { item = xi.item.VOLUSPA_BOW, cost = 80 },
            [14] = { item = xi.item.VOLUSPA_GUN, cost = 80 },
            [15] = { item = xi.item.VOLUSPA_GRIP, cost = 80 },
            [16] = { item = xi.item.VOLUSPA_SHIELD, cost = 80 },
        },
        [2] =
        {
            [1] = { item = xi.item.VOLUSPA_QUIVER, cost = 80 },
            [2] = { item = xi.item.VOLUSPA_BOLT_QUIVER, cost = 80 },
            [3] = { item = xi.item.VOLUSPA_BULLET_POUCH, cost = 80 },
            [4] = { item = xi.item.DATE_SHURIKEN_POUCH, cost = 80 },
        },
    },
    [4] =
    {
        [1] =
        {
            [1] = { item = xi.item.SANCTITY_NECKLACE, cost = 100 },
            [2] = { item = xi.item.GISHDUBAR_SASH, cost = 100 },
            [3] = { item = xi.item.EABANI_EARRING, cost = 100 },
            [4] = { item = xi.item.ETANA_RING, cost = 100 },
            [5] = { item = xi.item.IZDUBAR_MANTLE, cost = 100 },
            [6] = { item = xi.item.SOLEMNITY_CAPE, cost = 100 },
        },
    },
    [5] =
    {
        [1] =
        {
            [1] = { item = xi.item.INSTIGATOR, cost = 200 },
            [2] = { item = xi.item.HAMMERFISTS, cost = 200 },
            [3] = { item = xi.item.QUELLER_ROD, cost = 200 },
            [4] = { item = xi.item.LATHI, cost = 200 },
            [5] = { item = xi.item.EMISSARY, cost = 200 },
            [6] = { item = xi.item.SHIJO, cost = 200 },
            [7] = { item = xi.item.NIXXER, cost = 200 },
            [8] = { item = xi.item.DEATHBANE, cost = 200 },
            [9] = { item = xi.item.SKULLRENDER, cost = 200 },
            [10] = { item = xi.item.KALI, cost = 200 },
            [11] = { item = xi.item.VIJAYA_BOW, cost = 200 },
            [12] = { item = xi.item.ICHIGOHITOFURI, cost = 200 },
            [13] = { item = xi.item.AIZUSHINTOGO, cost = 200 },
            [14] = { item = xi.item.RHOMPHAIA, cost = 200 },
            [15] = { item = xi.item.ESPIRITUS, cost = 200 },
            [16] = { item = xi.item.IRIS, cost = 200 },
        },
        [2] =
        {
            [1] = { item = xi.item.COMPENSATOR, cost = 200 },
            [2] = { item = xi.item.MIDNIGHTS, cost = 200 },
            [3] = { item = xi.item.ENCHUFLA, cost = 200 },
            [4] = { item = xi.item.AKADEMOS, cost = 200 },
            [5] = { item = xi.item.SOLSTICE, cost = 200 },
            [6] = { item = xi.item.BIDENHANDER, cost = 200 },
        },
    },
    [6] =
    {
        [1] =
        {
            [1] = { item = xi.item.TRITON_ABJURATION_HEAD, cost = 400 },
            [2] = { item = xi.item.TRITON_ABJURATION_BODY, cost = 400 },
            [3] = { item = xi.item.TRITON_ABJURATION_HANDS, cost = 400 },
            [4] = { item = xi.item.TRITON_ABJURATION_LEGS, cost = 400 },
            [5] = { item = xi.item.TRITON_ABJURATION_FEET, cost = 400 },
            [6] = { item = xi.item.BUSHIN_ABJURATION_HEAD, cost = 400 },
            [7] = { item = xi.item.BUSHIN_ABJURATION_BODY, cost = 400 },
            [8] = { item = xi.item.BUSHIN_ABJURATION_HANDS, cost = 400 },
            [9] = { item = xi.item.BUSHIN_ABJURATION_LEGS, cost = 400 },
            [10] = { item = xi.item.BUSHIN_ABJURATION_FEET, cost = 400 },
            [11] = { item = xi.item.VALE_ABJURATION_HEAD, cost = 400 },
            [12] = { item = xi.item.VALE_ABJURATION_BODY, cost = 400 },
            [13] = { item = xi.item.VALE_ABJURATION_HANDS, cost = 400 },
            [14] = { item = xi.item.VALE_ABJURATION_LEGS, cost = 400 },
            [15] = { item = xi.item.VALE_ABJURATION_FEET, cost = 400 },
            [16] = { item = xi.item.GROVE_ABJURATION_HEAD, cost = 400 },
        },
        [2] =
        {
            [1] = { item = xi.item.GROVE_ABJURATION_BODY, cost = 400 },
            [2] = { item = xi.item.GROVE_ABJURATION_HANDS, cost = 400 },
            [3] = { item = xi.item.GROVE_ABJURATION_LEGS, cost = 400 },
            [4] = { item = xi.item.GROVE_ABJURATION_FEET, cost = 400 },
            [5] = { item = xi.item.ABYSSAL_ABJURATION_HEAD, cost = 400 },
            [6] = { item = xi.item.ABYSSAL_ABJURATION_BODY, cost = 400 },
            [7] = { item = xi.item.ABYSSAL_ABJURATION_HANDS, cost = 400 },
            [8] = { item = xi.item.ABYSSAL_ABJURATION_LEGS, cost = 400 },
            [9] = { item = xi.item.ABYSSAL_ABJURATION_FEET, cost = 400 },
            [10] = { item = xi.item.SHINRYU_ABJURATION_HEAD, cost = 400 },
            [11] = { item = xi.item.SHINRYU_ABJURATION_BODY, cost = 400 },
            [12] = { item = xi.item.SHINRYU_ABJURATION_HANDS, cost = 400 },
            [13] = { item = xi.item.SHINRYU_ABJURATION_LEGS, cost = 400 },
            [14] = { item = xi.item.SHINRYU_ABJURATION_FEET, cost = 400 },
            [15] = { item = xi.item.CRONIAN_ABJURATION_HEAD, cost = 400 },
            [16] = { item = xi.item.CRONIAN_ABJURATION_BODY, cost = 400 },
        },
        [3] =
        {
            [1] = { item = xi.item.CRONIAN_ABJURATION_HANDS, cost = 400 },
            [2] = { item = xi.item.CRONIAN_ABJURATION_LEGS, cost = 400 },
            [3] = { item = xi.item.CRONIAN_ABJURATION_FEET, cost = 400 },
            [4] = { item = xi.item.AREAN_ABJURATION_HEAD, cost = 400 },
            [5] = { item = xi.item.AREAN_ABJURATION_BODY, cost = 400 },
            [6] = { item = xi.item.AREAN_ABJURATION_HANDS, cost = 400 },
            [7] = { item = xi.item.AREAN_ABJURATION_LEGS, cost = 400 },
            [8] = { item = xi.item.AREAN_ABJURATION_FEET, cost = 400 },
            [9] = { item = xi.item.JOVIAN_ABJURATION_HEAD, cost = 400 },
            [10] = { item = xi.item.JOVIAN_ABJURATION_BODY, cost = 400 },
            [11] = { item = xi.item.JOVIAN_ABJURATION_HANDS, cost = 400 },
            [12] = { item = xi.item.JOVIAN_ABJURATION_LEGS, cost = 400 },
            [13] = { item = xi.item.JOVIAN_ABJURATION_FEET, cost = 400 },
            [14] = { item = xi.item.VENERIAN_ABJURATION_HEAD, cost = 400 },
            [15] = { item = xi.item.VENERIAN_ABJURATION_BODY, cost = 400 },
            [16] = { item = xi.item.VENERIAN_ABJURATION_HANDS, cost = 400 },
        },
                [4] =
                    {
            [1] = { item = xi.item.VENERIAN_ABJURATION_LEGS, cost = 400 },
            [2] = { item = xi.item.VENERIAN_ABJURATION_FEET, cost = 400 },
            [3] = { item = xi.item.CYLLENIAN_ABJURATION_HEAD, cost = 400 },
            [4] = { item = xi.item.CYLLENIAN_ABJURATION_BODY, cost = 400 },
            [5] = { item = xi.item.CYLLENIAN_ABJURATION_HANDS, cost = 400 },
            [6] = { item = xi.item.CYLLENIAN_ABJURATION_LEGS, cost = 400 },
            [7] = { item = xi.item.CYLLENIAN_ABJURATION_FEET, cost = 400 },
                    },
    },
    [7] =
    {
        [1] =
        {
            [1] = { item = xi.item.HRETHA_EARRING, cost = 600 },
            [2] = { item = xi.item.RAN_EARRING, cost = 600 },
            [3] = { item = xi.item.FORESTI_EARRING, cost = 600 },
            [4] = { item = xi.item.HERMODR_EARRING, cost = 600 },
            [5] = { item = xi.item.SAXNOT_EARRING, cost = 600 },
            [6] = { item = xi.item.MEILI_EARRING, cost = 600 },
            [7] = { item = xi.item.MIMIR_EARRING, cost = 600 },
            [8] = { item = xi.item.VOR_EARRING, cost = 600 },
            [9] = { item = xi.item.ILMR_EARRING, cost = 600 },
            [10] = { item = xi.item.MANI_EARRING, cost = 600 },
            [11] = { item = xi.item.LODURR_EARRING, cost = 600 },
            [12] = { item = xi.item.NJORDR_EARRING, cost = 600 },
            [13] = { item = xi.item.BRAGI_EARRING, cost = 600 },
            [14] = { item = xi.item.DELLINGR_EARRING, cost = 600 },
            [15] = { item = xi.item.GERSEMI_EARRING, cost = 600 },
            [16] = { item = xi.item.HNOSS_EARRING, cost = 600 },
        },
        [2] =
        {
            [1] = { item = xi.item.GNA_EARRING, cost = 600 },
            [2] = { item = xi.item.FULLA_EARRING, cost = 600 },
        },
    },
    [8] =
    {
        [1] =
        {
            [1] = { item = xi.item.CONDEMNERS, cost = 800 },
            [2] = { item = xi.item.SKINFLAYER, cost = 800 },
            [3] = { item = xi.item.COLADA, cost = 800 },
            [4] = { item = xi.item.ZULFIQAR, cost = 800 },
            [5] = { item = xi.item.DIGIRBALAG, cost = 800 },
            [6] = { item = xi.item.AGANOSHE, cost = 800 },
            [7] = { item = xi.item.REIENKYO, cost = 800 },
            [8] = { item = xi.item.OBSCHINE, cost = 800 },
            [9] = { item = xi.item.KANARIA, cost = 800 },
            [10] = { item = xi.item.UMARU, cost = 800 },
            [11] = { item = xi.item.GADA, cost = 800 },
            [12] = { item = xi.item.GRIOAVOLR, cost = 800 },
            [13] = { item = xi.item.TELLER, cost = 800 },
            [14] = { item = xi.item.HOLLIDAY, cost = 800 },
            [15] = { item = xi.item.ODYSSEAN_HELM, cost = 800 },
            [16] = { item = xi.item.ODYSSEAN_CHESTPLATE, cost = 800 },
        },
        [2] =
        {
            [1] = { item = xi.item.ODYSSEAN_GAUNTLETS, cost = 800 },
            [2] = { item = xi.item.ODYSSEAN_CUISSES, cost = 800 },
            [3] = { item = xi.item.ODYSSEAN_GREAVES, cost = 800 },
            [4] = { item = xi.item.VALOROUS_MASK, cost = 800 },
            [5] = { item = xi.item.VALOROUS_MAIL, cost = 800 },
            [6] = { item = xi.item.VALOROUS_MITTS, cost = 800 },
            [7] = { item = xi.item.VALOROUS_HOSE, cost = 800 },
            [8] = { item = xi.item.VALOROUS_GREAVES, cost = 800 },
            [9] = { item = xi.item.HERCULEAN_HELM, cost = 800 },
            [10] = { item = xi.item.HERCULEAN_VEST, cost = 800 },
            [11] = { item = xi.item.HERCULEAN_GLOVES, cost = 800 },
            [12] = { item = xi.item.HERCULEAN_TROUSERS, cost = 800 },
            [13] = { item = xi.item.HERCULEAN_BOOTS, cost = 800 },
            [14] = { item = xi.item.CHIRONIC_HAT, cost = 800 },
            [15] = { item = xi.item.CHIRONIC_DOUBLET, cost = 800 },
            [16] = { item = xi.item.CHIRONIC_GLOVES, cost = 800 },
        },
        [3] =
        {
            [1] = { item = xi.item.CHIRONIC_HOSE, cost = 800 },
            [2] = { item = xi.item.CHIRONIC_SLIPPERS, cost = 800 },
            [3] = { item = xi.item.MERLINIC_HOOD, cost = 800 },
            [4] = { item = xi.item.MERLINIC_JUBBAH, cost = 800 },
            [5] = { item = xi.item.MERLINIC_DASTANAS, cost = 800 },
            [6] = { item = xi.item.MERLINIC_SHALWAR, cost = 800 },
            [7] = { item = xi.item.MERLINIC_CRACKOWS, cost = 800 },
        },
    },
    [9] =
    {
        [1] =
        {
            [1] = { item = xi.item.HAUKSBOK_ARROW, cost = 1000 },
            [2] = { item = xi.item.HAUKSBOK_BOLT, cost = 1000 },
            [3] = { item = xi.item.HAUKSBOK_BULLET, cost = 1000 },
            [4] = { item = xi.item.VOLUSPA_TATHLUM, cost = 1000 },
            [5] = { item = xi.item.YNGVI_CHOKER, cost = 1000 },
            [6] = { item = xi.item.THRUD_EARRING, cost = 1000 },
            [7] = { item = xi.item.ODR_EARRING, cost = 1000 },
            [8] = { item = xi.item.SNOTRA_EARRING, cost = 1000 },
            [9] = { item = xi.item.SJOFN_EARRING, cost = 1000 },
            [10] = { item = xi.item.BEYLA_EARRING, cost = 1000 },
            [11] = { item = xi.item.TUISTO_EARRING, cost = 1000 },
            [12] = { item = xi.item.NEHALENNIA_EARRING, cost = 1000 },
            [13] = { item = xi.item.DREKI_RING, cost = 1000 },
            [14] = { item = xi.item.ASK_SASH, cost = 1000 },
            [15] = { item = xi.item.EMBLA_SASH, cost = 1000 },
            [16] = { item = xi.item.AUDUMBLA_SASH, cost = 1000 },
        },
    },
    [10] =
    {
        [1] =
        {
            [1] = { item = xi.item.PILE_OF_WYRM_ASH, cost = 1200 },
        },
    },
}
