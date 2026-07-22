-----------------------------------
-- Proto-Waypoints (Ru'Lude Gardens / Rabao / Selbina / Mhaura / Norg).
--
-- Retail (bg-wiki "Proto-Waypoint"): travel between the five town
-- Proto-Waypoints costs 30 kinetic units; one-way trips to attuned
-- Geomagnetic Founts cost 100 (field) / 300 (dungeon) units. Retail gates
-- attunement behind "Researchers from the West"; here the first examine
-- attunes that town's Proto-Waypoint (CharVar bitmask) — no quest gate.
--
-- Each town's menu is its own client event (decoded from the DAT dumps: an
-- identical 2,833-byte program per town — top menu + destination confirms).
-- The update leg debits kinetic units exactly like the Adoulin waypoints
-- (cost = option >> 21). The finish leg's option→destination mapping is
-- calibrated from the first live picks; unmapped options are echoed to the
-- player so every pick contributes calibration data.
-----------------------------------
require('scripts/globals/geomagnetic_fount')
-----------------------------------
xi = xi or {}
xi.protoWaypoint = xi.protoWaypoint or {}

local attunedVar = 'ProtoWaypoints_Attuned'

-- slot = bit in the attunement mask; eventId = the town's travel-menu event.
local protoData =
{
    [xi.zone.RULUDE_GARDENS] = { slot = 0, eventId = 10209, pos = { -37.819,  0.001, -39.911,  64 } },
    [xi.zone.RABAO]          = { slot = 1, eventId =   141, pos = {  15.927,  7.999,  11.149,  64 } },
    [xi.zone.SELBINA]        = { slot = 2, eventId = 10012, pos = { -31.376, -0.777, -29.603,  64 } },
    [xi.zone.MHAURA]         = { slot = 3, eventId =   345, pos = {  42.229, -16.049, 84.699,  64 } },
    [xi.zone.NORG]           = { slot = 4, eventId =   266, pos = { -79.652, -1.313,  40.287,  64 } },
}

-- Geomagnetic Founts: destination-only arrival points, attuned by clicking
-- once on foot (retail). slot = bit in the two attunement mask CharVars
-- (0-31 in mask 1, 32+ in mask 2); cost = kinetic units from a proto-waypoint
-- (100 field / 300 dungeon, per bg-wiki).
local fountData =
{
    [xi.zone.ULEGUERAND_RANGE]       = { slot = 0,  cost = 100, pos = {   58.442, -199.381,  177.396, 1 } },
    [xi.zone.ATTOHWA_CHASM]          = { slot = 1,  cost = 100, pos = {  288.633,  -21.752,   25.448, 1 } },
    [xi.zone.OLDTON_MOVALPOLOS]      = { slot = 2,  cost = 300, pos = {  177.549,    7.378,  -97.327, 1 } },
    [xi.zone.RIVERNE_SITE_B01]       = { slot = 3,  cost = 300, pos = { -827.142,  -45.357,  140.238, 1 } },
    [xi.zone.WEST_RONFAURE]          = { slot = 4,  cost = 100, pos = { -704.875,  -39.455,   22.311, 1 } },
    [xi.zone.LA_THEINE_PLATEAU]      = { slot = 5,  cost = 100, pos = { -410.523,   51.986, -362.174, 1 } },
    [xi.zone.JUGNER_FOREST]          = { slot = 6,  cost = 100, pos = { -178.000,   -4.205,  502.233, 1 } },
    [xi.zone.NORTH_GUSTABERG]        = { slot = 7,  cost = 100, pos = { -676.965,   98.500,  356.421, 1 } },
    [xi.zone.PASHHOW_MARSHLANDS]     = { slot = 8,  cost = 100, pos = {  209.580,   25.000,  148.673, 1 } },
    [xi.zone.WEST_SARUTABARUTA]      = { slot = 9,  cost = 100, pos = { -267.979,  -18.967,  660.177, 1 } },
    [xi.zone.TAHRONGI_CANYON]        = { slot = 10, cost = 100, pos = {  128.307,  -10.104, -177.120, 1 } },
    [xi.zone.MERIPHATAUD_MOUNTAINS]  = { slot = 11, cost = 100, pos = {   42.448,    5.239,   50.973, 1 } },
    [xi.zone.YUGHOTT_GROTTO]         = { slot = 12, cost = 300, pos = {  199.133,  -11.515,  110.606, 1 } },
    [xi.zone.PALBOROUGH_MINES]       = { slot = 13, cost = 300, pos = {  294.324,  -17.043,   99.687, 1 } },
    [xi.zone.BEADEAUX]               = { slot = 14, cost = 300, pos = { -101.001,   23.615,  111.017, 1 } },
    [xi.zone.DAVOI]                  = { slot = 15, cost = 300, pos = { -107.439,   -5.014, -107.439, 1 } },
    [xi.zone.MONASTIC_CAVERN]        = { slot = 16, cost = 300, pos = {    0.000,    0.000, -312.000, 1 } },
    [xi.zone.CASTLE_OZTROJA]         = { slot = 17, cost = 300, pos = { -130.954,    0.122,  -20.926, 1 } },
    [xi.zone.THE_BOYAHDA_TREE]       = { slot = 18, cost = 300, pos = {   25.111,    5.771,  131.153, 1 } },
    [xi.zone.TEMPLE_OF_UGGALEPIH]    = { slot = 19, cost = 300, pos = { -103.000,    0.001,  -16.000, 1 } },
    [xi.zone.CASTLE_ZVAHL_KEEP]      = { slot = 20, cost = 300, pos = { -368.364,    0.001,  -18.744, 1 } },
    [xi.zone.RANGUEMONT_PASS]        = { slot = 21, cost = 300, pos = {  166.183,   25.221, -191.464, 1 } },
    [xi.zone.TORAIMARAI_CANAL]       = { slot = 22, cost = 300, pos = {  -60.004,   21.503,  194.314, 1 } },
    [xi.zone.KORROLOKA_TUNNEL]       = { slot = 23, cost = 300, pos = { -112.997,    1.500, -103.864, 1 } },
    [xi.zone.SEA_SERPENT_GROTTO]     = { slot = 24, cost = 300, pos = {  -59.830,   18.805,   92.782, 1 } },
    [xi.zone.KING_RANPERRES_TOMB]    = { slot = 25, cost = 300, pos = {  223.311,   -0.261,  175.141, 1 } },
    [xi.zone.DANGRUF_WADI]           = { slot = 26, cost = 300, pos = { -480.364,    2.458,  -58.355, 1 } },
    [xi.zone.INNER_HORUTOTO_RUINS]   = { slot = 27, cost = 300, pos = {   41.312,    0.001,   81.860, 1 } },
    [xi.zone.ORDELLES_CAVES]         = { slot = 28, cost = 300, pos = { -182.376,   28.415, -139.829, 1 } },
    [xi.zone.OUTER_HORUTOTO_RUINS]   = { slot = 29, cost = 300, pos = {  289.792,    0.001,  708.071, 1 } },
    [xi.zone.THE_ELDIEME_NECROPOLIS] = { slot = 30, cost = 300, pos = {   51.805,   -2.495,    6.825, 1 } },
    [xi.zone.GUSGEN_MINES]           = { slot = 31, cost = 300, pos = {  -79.402,  -27.000,  439.369, 1 } },
    [xi.zone.CRAWLERS_NEST]          = { slot = 32, cost = 300, pos = { -137.728,  -32.314,   33.123, 1 } },
    [xi.zone.MAZE_OF_SHAKHRAMI]      = { slot = 33, cost = 300, pos = {  289.404,   -6.741, -149.664, 1 } },
    [xi.zone.GARLAIGE_CITADEL]       = { slot = 34, cost = 300, pos = { -156.374,    0.000,  237.283, 1 } },
    [xi.zone.QUICKSAND_CAVES]        = { slot = 35, cost = 300, pos = { -896.722,   -1.698, -375.598, 1 } },
    [xi.zone.GUSTAV_TUNNEL]          = { slot = 36, cost = 300, pos = {  -71.932,   -8.897, -209.707, 1 } },
    [xi.zone.LABYRINTH_OF_ONZOZO]    = { slot = 37, cost = 300, pos = {  136.955,   14.892,  185.412, 1 } },
}

local fountMaskVar = function(slot)
    return slot < 32 and 'GeoFounts_Attuned_1' or 'GeoFounts_Attuned_2'
end

xi.protoWaypoint.fountOnTrigger = function(player, npc)
    -- SoA mission "The Geomagnetron" interaction first (only in zones whose
    -- text table carries the message).
    local ID = zones[player:getZoneID()]
    if ID and ID.text and ID.text.GEOMAGNETRON_ATTUNED then
        xi.geomagneticFount.checkFount(player, npc)
    end

    local entry = fountData[player:getZoneID()]
    if not entry then
        return
    end

    local varName = fountMaskVar(entry.slot)
    local bitPos  = entry.slot % 32
    local mask    = player:getCharVar(varName)

    if bit.band(bit.rshift(mask, bitPos), 1) == 0 then
        player:setCharVar(varName, bit.bor(mask, bit.lshift(1, bitPos)))
        player:printToPlayer('The geomagnetic fount pulses in recognition. You may now travel here from any proto-waypoint.', xi.msg.channel.NS_SAY)
    end
end

-- option (onEventFinish) -> destination zone. Filled in as live picks are
-- calibrated; picks with no entry are echoed for calibration.
local optionDestinations =
{
}

xi.protoWaypoint.onTrigger = function(player, npc)
    local zoneId = player:getZoneID()
    local entry  = protoData[zoneId]
    if not entry then
        return
    end

    local mask = player:getCharVar(attunedVar)
    if bit.band(bit.rshift(mask, entry.slot), 1) == 0 then
        player:setCharVar(attunedVar, bit.bor(mask, bit.lshift(1, entry.slot)))
        player:printToPlayer('The proto-waypoint hums to life, attuning itself to your presence.', xi.msg.channel.NS_SAY)
        return
    end

    -- Same first-parameter packing as the Adoulin waypoints: kinetic units
    -- high, menu params (4 = discounted-cost flag retail always sets), index.
    local p0 = bit.lshift(player:getCurrency('kinetic_unit'), 16) + bit.lshift(4, 12)
    player:startEvent(
        entry.eventId,
        p0,
        player:getCharVar(attunedVar),
        player:getCharVar('GeoFounts_Attuned_1'),
        player:getCharVar('GeoFounts_Attuned_2'),
        0,
        0,
        0
    )
end

xi.protoWaypoint.onEventUpdate = function(player, csid, option, npc)
    local travelCost = bit.rshift(option, 21)

    if player:getCurrency('kinetic_unit') >= travelCost then
        player:delCurrency('kinetic_unit', travelCost)
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, 1)
    else
        player:printToPlayer('You do not hold enough kinetic units for that trip.', xi.msg.channel.NS_SAY)
        player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
    end
end

xi.protoWaypoint.onEventFinish = function(player, csid, option, npc)
    if option == 0 or bit.band(option, 0x40000000) ~= 0 then
        return
    end

    local destZone = optionDestinations[bit.band(option, 0x7F)]
    if not destZone then
        player:printToPlayer(string.format('Proto-waypoint: unmapped destination pick (option 0x%X) — report this.', option), xi.msg.channel.NS_SAY)
        return
    end

    local dest = protoData[destZone] or fountData[destZone]
    player:setPos(dest.pos[1], dest.pos[2], dest.pos[3], dest.pos[4], destZone)
end
