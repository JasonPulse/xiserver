-----------------------------------
-- Adoulin Coalition IDs and per-coalition CharVar mapping.
--
-- Backing store is CharVars (see `scripts/globals/coalition.lua` for the
-- read/write API). Names here must stay in sync with the keys read by
-- `src/map/packets/s2c/0x071_influence_colonization.cpp` — change one,
-- change the other.
-----------------------------------
xi = xi or {}

---@enum xi.coalition
xi.coalition =
{
    PIONEERS     = 1,
    PEACEKEEPERS = 2,
    COURIERS     = 3,
    SCOUTS       = 4,
    INVENTORS    = 5,
    MUMMERS      = 6,
}

-- Packet field is 4 bits per coalition, so 0..15.
xi.coalition.MAX_RANK = 15

xi.coalition.IMPRIMATURS_VAR = 'Coalition_Imprimaturs_Spent'

xi.coalition.varNames =
{
    [xi.coalition.PIONEERS]     = 'Coalition_Pioneers_Rank',
    [xi.coalition.PEACEKEEPERS] = 'Coalition_Peacekeepers_Rank',
    [xi.coalition.COURIERS]     = 'Coalition_Couriers_Rank',
    [xi.coalition.SCOUTS]       = 'Coalition_Scouts_Rank',
    [xi.coalition.INVENTORS]    = 'Coalition_Inventors_Rank',
    [xi.coalition.MUMMERS]      = 'Coalition_Mummers_Rank',
}
