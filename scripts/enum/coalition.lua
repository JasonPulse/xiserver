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

xi.coalition.displayNames =
{
    [xi.coalition.PIONEERS]     = 'Pioneers',
    [xi.coalition.PEACEKEEPERS] = 'Peacekeepers',
    [xi.coalition.COURIERS]     = 'Couriers',
    [xi.coalition.SCOUTS]       = 'Scouts',
    [xi.coalition.INVENTORS]    = 'Inventors',
    [xi.coalition.MUMMERS]      = 'Mummers',
}

-- Imprimatur cost to advance from rank N to rank N+1 (index = current rank).
-- Approximates retail edification curve; tuned for our small-server pacing
-- so Task_Delegator's daily 100-imprimatur trickle is meaningful but not free.
xi.coalition.RANK_UP_COSTS =
{
    [1]  =   500,
    [2]  =  1000,
    [3]  =  2000,
    [4]  =  3000,
    [5]  =  5000,
    [6]  =  7500,
    [7]  = 10000,
    [8]  = 12500,
    [9]  = 15000,
    [10] = 20000,
    [11] = 25000,
    [12] = 30000,
    [13] = 40000,
    [14] = 50000,
}

-- Optional GM override: per-player CharVar that pins edification to a single
-- coalition id (1..6). When 0/unset the edifier auto-picks the lowest rank.
xi.coalition.EDIFY_TARGET_VAR = 'Coalition_Edify_Target'
