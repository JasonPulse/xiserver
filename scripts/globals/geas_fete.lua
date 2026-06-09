-----------------------------------
-- Geas Fete
--
-- Retail: Escha-Zi'Tah / Escha-Ru'Aun / Reisenjima NMs are popped by trading
-- a unique pop key item (the NM's "trophy" item) to the Geas Fete handler
-- at the relevant zone. Defeat awards Sense of Eminence, mercenary rank
-- progress, plus the standard NM droplist.
--
-- Status BEFORE this module: 80+ pop KIs exist in scripts/enum/key_item.lua
-- (range 2890..3000 ish); mob_pools + mob_spawn_points for the bosses are
-- present in Escha-Ru'Aun (zone 289), Reisenjima (291), and the
-- ZiTah/Reisenjima variants. Missing: any pop / death handler. Zero infra.
--
-- This module's job (matches Wildskeeper Reives pattern):
--   1. xi.geasFete.popBoss(player, kiId) — consume the pop KI, SpawnMob the
--      corresponding boss at its retail coords. Returns (true, label) or
--      (false, reason).
--   2. xi.geasFete.grantRewards(mob, player) — call from each NM's onMobDeath;
--      awards bayld to alliance in range and bumps a defeated counter.
--
-- The pop table covers a "Tier 1" starter set (5 Gods + 5 Ark Angels in
-- Escha-Ru'Aun, plus 8 standard Escha-ZiTah/Ru'Aun NMs and 3 Reisenjima
-- bosses). The remaining ~60 Geas Fete NMs follow the same pattern — extend
-- xi.geasFete.pops with `{ label, mobName, zoneId }` as needed.
-----------------------------------
xi = xi or {}
xi.geasFete = xi.geasFete or {}

xi.geasFete.pops =
{
    -- Tier-1 Gods (Escha-Ru'Aun, all in zone 289)
    [xi.ki.BYAKKOS_PRIDE]          = { label = 'Byakko',  mobName = 'Byakko',  zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.GENBUS_HONOR]           = { label = 'Genbu',   mobName = 'Genbu',   zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.SEIRYUS_NOBILITY]       = { label = 'Seiryu',  mobName = 'Seiryu',  zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.SUZAKUS_BENEFACTION]    = { label = 'Suzaku',  mobName = 'Suzaku',  zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.KIRINS_FERVOR]          = { label = 'Kirin',   mobName = 'Kirin',   zoneId = xi.zone.ESCHA_RUAUN },

    -- Ark Angels (Escha-Ru'Aun)
    [xi.ki.ARK_ANGEL_HMS_COAT]     = { label = 'Ark Angel HM', mobName = 'Ark_Angel_HM', zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.ARK_ANGEL_TTS_NECKLACE] = { label = 'Ark Angel TT', mobName = 'Ark_Angel_TT', zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.ARK_ANGEL_MRS_BUCKLE]   = { label = 'Ark Angel MR', mobName = 'Ark_Angel_MR', zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.ARK_ANGEL_EVS_SASH]     = { label = 'Ark Angel EV', mobName = 'Ark_Angel_EV', zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.ARK_ANGEL_GKS_BANGLE]   = { label = 'Ark Angel GK', mobName = 'Ark_Angel_GK', zoneId = xi.zone.ESCHA_RUAUN },

    -- Standard Escha-Ru'Aun NMs
    [xi.ki.BIAS_GLOVE]             = { label = 'Bia',         mobName = 'Bia',         zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.RUEAS_STONE]            = { label = 'Ruea',        mobName = 'Ruea',        zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.MAS_LANCE]              = { label = 'Ma',          mobName = 'Ma',          zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.KHONS_SCEPTER]          = { label = 'Khon',        mobName = 'Khon',        zoneId = xi.zone.ESCHA_RUAUN },
    [xi.ki.KHUNS_CROWN]            = { label = 'Khun',        mobName = 'Khun',        zoneId = xi.zone.ESCHA_RUAUN },

    -- Standard Escha-ZiTah NMs (sample)
    [xi.ki.WEPWAWETS_TOOTH]        = { label = 'Wepwawet',    mobName = 'Wepwawet',    zoneId = xi.zone.ESCHA_ZITAH },
    [xi.ki.AGLAOPHOTIS_BUD]        = { label = 'Aglaophotis', mobName = 'Aglaophotis', zoneId = xi.zone.ESCHA_ZITAH },
    [xi.ki.VYALAS_PREY]            = { label = 'Vyala',       mobName = 'Vyala',       zoneId = xi.zone.ESCHA_ZITAH },

    -- Reisenjima bosses (sample)
    [xi.ki.BELPHEGORS_CROWN]       = { label = 'Belphegor',   mobName = 'Belphegor',   zoneId = xi.zone.REISENJIMA },
    [xi.ki.CROM_DUBHS_HELM]        = { label = 'Crom Dubh',   mobName = 'Crom_Dubh',   zoneId = xi.zone.REISENJIMA },
    [xi.ki.KABANDHAS_WING]         = { label = 'Kabandha',    mobName = 'Kabandha',    zoneId = xi.zone.REISENJIMA },
}

local bayldReward      = 3000  -- per alliance member on kill
local rewardRadius     = 100   -- yalms

xi.geasFete.popBoss = function(player, kiId)
    if not player or not kiId then
        return false, 'invalid args'
    end

    local entry = xi.geasFete.pops[kiId]
    if not entry then
        return false, 'kiId is not a registered Geas Fete pop item'
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

xi.geasFete.grantRewards = function(mob, player)
    if not mob or not player then
        return
    end

    local mobName     = mob:getName()
    local defeatedVar = string.format('GeasFete_%s_Defeated', mobName)
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
