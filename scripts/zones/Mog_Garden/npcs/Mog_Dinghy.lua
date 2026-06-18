-----------------------------------
-- Area: Mog Garden
--  NPC: Mog Dinghy — travel hub
-- !zone 280
-----------------------------------
-- Retail Mog Dinghy is a multi-destination warp menu via CSID 1015. The
-- pinned client version (30251227_0) only reliably hands back option values
-- for the first 3 menu slots (Whence I came / Western Adoulin / Eastern
-- Adoulin) — those continue to work below.
--
-- All 8 retail destinations are reachable via the `Mog_Dinghy_Selection`
-- CharVar pin, matching the rest of this server's opt-in selection systems
-- (Coalition_Edify_Target, Atma_Selection, Pop_Selection, etc.):
--
--   !setvar Mog_Dinghy_Selection N    (where N is one of:)
--     1 = Selbina
--     2 = Mhaura
--     3 = Nashmau
--     4 = Tavnazian Safehold
--     5 = Aht Urhgan Whitegate
--     6 = Western Adoulin
--     7 = Eastern Adoulin
--     8 = warp back to home point
--
-- Then trigger the Mog Dinghy. The pin is consumed on warp.
-- Coords below come from existing quest/mission scripts that warp players to
-- the same zones; ferry-style `(0,0,0,0,zone)` falls back to each zone's
-- default zone-line, which is the same pattern the existing
-- `Ship_bound_for_*` / `Open_sea_route_*` Zone.lua scripts use.
-----------------------------------
---@type TNpcEntity
local entity = {}

local mogDinghySelectionVar = 'Mog_Dinghy_Selection'

local destinations =
{
    [1] = { name = 'Selbina',                x =  0,      y =   0, z =    0,    rot =  0, zone = xi.zone.SELBINA                },
    [2] = { name = 'Mhaura',                 x =  8,      y =  -1, z =    5,    rot = 62, zone = xi.zone.MHAURA                 },
    [3] = { name = 'Nashmau',                x =  0,      y =   0, z =    0,    rot =  0, zone = xi.zone.NASHMAU                },
    [4] = { name = 'Tavnazian Safehold',     x =  0,      y =   0, z =    0,    rot =  0, zone = xi.zone.TAVNAZIAN_SAFEHOLD     },
    [5] = { name = 'Aht Urhgan Whitegate',   x = 80,      y =  -6, z = -123,    rot = 65, zone = xi.zone.AHT_URHGAN_WHITEGATE   },
    [6] = { name = 'Western Adoulin',        x =  0,      y =   0, z =    0,    rot =  0, zone = xi.zone.WESTERN_ADOULIN        },
    [7] = { name = 'Eastern Adoulin',        x = 91.751,  y = -40, z =  -63.998, rot = 127, zone = xi.zone.EASTERN_ADOULIN      },
}

local function tryPinnedWarp(player)
    local pinned = player:getCharVar(mogDinghySelectionVar)
    if pinned == 0 then
        return false
    end

    if pinned == 8 then
        player:setCharVar(mogDinghySelectionVar, 0)
        player:warp()
        return true
    end

    local dest = destinations[pinned]
    if not dest then
        player:printToPlayer(string.format('Mog_Dinghy_Selection %d is not a valid destination (1-8). See Mog_Dinghy.lua.', pinned))
        return true
    end

    player:setCharVar(mogDinghySelectionVar, 0)
    player:printToPlayer(string.format('Sailing to %s...', dest.name))
    player:setPos(dest.x, dest.y, dest.z, dest.rot, dest.zone)
    return true
end

entity.onTrigger = function(player, npc)
    if tryPinnedWarp(player) then
        return
    end

    player:startEvent(1015, 1, 1, 1, 1, 1, 1, 1, 1)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 1015 then
        if option == 1 then -- Whence I came
            player:warp()
        elseif option == 2 then -- Western Adoulin (menu slot 2)
            player:setPos(0, 0, 0, 0, xi.zone.WESTERN_ADOULIN)
        elseif option == 3 then -- Eastern Adoulin (menu slot 3)
            player:setPos(0, 0, 0, 0, xi.zone.EASTERN_ADOULIN)
        end
    end
end

return entity
