-----------------------------------
-- Sinister Reign — Lhe Lhangavo dispatch global.
--
-- Sinister Reign is a series of 9 boss battlefields in the SoA-era
-- Adoulin zones (Foret de Hennetiel, Yorcia Weald, Cirdas Caverns, etc).
-- Players are dispatched by Lhe Lhangavo in Western Adoulin / Eastern
-- Adoulin / Ceizak Battlegrounds / Sih Gates, who fires their CSIDs.
--
-- All 4 Lhe Lhangavo NPCs have only sentinel-byte CSIDs (1-7 bytes).
-- The real event programs live in event#.dat — firing the CSID lets
-- the engine's event VM run the retail dispatch logic. Same shape as
-- the Voidwatch_Officer sentinels.
--
-- Battle implementation (mob spawning, win detection, reward grants)
-- is NOT shipped here — Sinister Reign battlefield mobs aren't in our
-- mob_pools.sql yet. This module only handles the dispatcher entry
-- flow so players can discover the system in-game.
-----------------------------------
xi = xi or {}
xi.sinisterReign = xi.sinisterReign or {}

-- Entry CSIDs per zone (verified via xidat against entities
-- 17825940 / 17830040 / 17846786 / 17875320).
xi.sinisterReign.entryCsid =
{
    [xi.zone.WESTERN_ADOULIN]    = 5023,
    [xi.zone.EASTERN_ADOULIN]    = 1500,
    [xi.zone.CEIZAK_BATTLEGROUNDS] = 19,
    [xi.zone.SIH_GATES]          = 13,
}

xi.sinisterReign.lheLhangavoOnTrigger = function(player, npc, label)
    local zoneId = player:getZoneID()
    local csid   = xi.sinisterReign.entryCsid[zoneId]

    if not csid then
        player:printToPlayer('Lhe Lhangavo has no Sinister Reign dispatch event in this zone.')
        return
    end

    local bayld = player:getCurrency('bayld')

    printf('[Lhe_Lhangavo_%s] onTrigger: zone=%d csid=%d bayld=%d',
        label, zoneId, csid, bayld)

    player:startEvent(csid, bayld, 0, 0, 0, 0, 0, 0)
end

xi.sinisterReign.lheLhangavoOnEventUpdate = function(player, csid, option, label)
    printf('[Lhe_Lhangavo_%s] onEventUpdate: csid=%d option=%d (0x%08X)', label, csid, option, option)
end

xi.sinisterReign.lheLhangavoOnEventFinish = function(player, csid, option, label)
    printf('[Lhe_Lhangavo_%s] onEventFinish: csid=%d option=%d (0x%08X)', label, csid, option, option)
end
