-----------------------------------
-- Simplified Sky / Sea access (4-player private server).
--
-- Retail Sky (Tu'Lia) is gated behind the Ascension quest line (Divine
-- Might, Trial by Fire/Wind/Water/Lightning, ZM-14 The Celestial Nexus).
-- Retail Sea (Al'Taieu) is gated behind CoP missions through 7-5
-- (Empty's Theme). This module bypasses both gates: player pins Sky or
-- Sea, the next onGameIn warps them to the city/zone entry.
--
-- Once inside, the existing mob/NPC scripts (Genbu/Suzaku/Byakko/Seiryu
-- + Kirin in Shrine of Ru'Avitau; Sea NMs in Al'Taieu / Grand Palace of
-- Hu'Xzoi) handle gameplay.
--
-- Usage:
--   !setvar Sky_Selection N        (1=Tu'Lia / Ru'Aun Gardens,
--                                   2=Sea / Al'Taieu,
--                                   3=Limbus / Temenos,
--                                   4=Limbus / Apollyon)
--   then zone / relog
--
-- Temenos has no retail entrance implemented (the Grand Palace vortex was
-- never captured), so the pin is its only way in. Apollyon is also
-- reachable the retail way: Al'Taieu Swirling Vortices. Neither Limbus
-- lobby has an exit vortex — leave with warp/Instant Warp. Battlefield
-- entry inside needs Cosmo-Cleanse + the area's card KI.
--
-- Free — no Imperial Standing cost. These are travel gates, not battle
-- entries. If you want to gate behind a setting, add SKY_ACCESS_COST.
-----------------------------------
xi = xi or {}
xi.skyAccess = xi.skyAccess or {}

local skyPinVar = 'Sky_Selection'

local destinations =
{
    -- Ru'Aun directly, not Hall of the Gods: the Shimmering Circle up is gated
    -- on ZM6 The Gate of the Gods, so fresh characters warped into the Hall
    -- were stuck in the antechamber. (0,0,0) triggers Ru'Aun's Zone.lua
    -- default-arrival placement.
    [1] = { name = 'Tu\'Lia (Ru\'Aun Gardens)', zone = xi.zone.RUAUN_GARDENS, x = 0, y = 0, z = 0, rot = 0 },
    [2] = { name = 'Sea (Al\'Taieu)',           zone = xi.zone.ALTAIEU,       x = 0, y = 0, z = 0, rot = 0 },
    [3] = { name = 'Limbus (Temenos)',          zone = xi.zone.TEMENOS,       x = 0, y = 0, z = 0, rot = 0 },
    [4] = { name = 'Limbus (Apollyon)',         zone = xi.zone.APOLLYON,      x = -668, y = 0.1, z = -666, rot = 209 },
}

xi.skyAccess.tryWarp = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(skyPinVar)
    if pinned == 0 then
        return false
    end

    local dest = destinations[pinned]
    if not dest then
        player:printToPlayer(string.format('Sky_Selection %d is not valid (1=Tu\'Lia, 2=Sea, 3=Temenos, 4=Apollyon). See sky_access.lua.', pinned))
        player:setCharVar(skyPinVar, 0)
        return true
    end

    -- Consume the pin and delay the warp: setPos silently returns early
    -- when player.status == DISAPPEAR (the status during the zone-in
    -- callback chain). Delay 3s lets the engine flip status to NORMAL
    -- before we initiate the cross-zone warp.
    player:setCharVar(skyPinVar, 0)
    player:printToPlayer(string.format('Warping to %s...', dest.name))
    player:timer(3000, function(p)
        p:setPos(dest.x, dest.y, dest.z, dest.rot, dest.zone)
    end)

    return true
end
