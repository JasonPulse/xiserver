-----------------------------------
-- Mog Garden location IDs.
--
-- These live in scripts/enum rather than in scripts/globals/mog_garden.lua because the
-- globals walk is recursive and sorted as std::set<std::filesystem::path>, which
-- compares path COMPONENTS: 'globals/mog_garden' sorts before 'globals/mog_garden.lua',
-- so scripts/globals/mog_garden/vendor.lua and yields.lua both execute BEFORE their
-- parent. Anything they need at load time has to already exist, and scripts/enum is
-- loaded first of all, before utils, data and globals alike.
--
-- Same split as xi.coalition: the values are declared here, the behaviour lives in
-- scripts/globals/mog_garden.lua.
--
-- The order is the client's own, taken three times over: the debug rank menu in the Mog
-- Garden dialog table (7556 "Furrows / Grove / Vein / Pond / Coast / M"), the
-- family-major layout of the vendors' event data tables, and the Skipper Moogle's
-- per-book description (11803 "the rank of your [furrows/arboreal grove/mineral vein/
-- pond dredger/coastal fishing net/monster rearing skills]"). The value therefore
-- doubles as the family index the shop speaks in, which is why it starts at zero.
-----------------------------------
xi = xi or {}
xi.mog_garden = xi.mog_garden or {}

---@enum xi.mog_garden.location
xi.mog_garden.location =
{
    FURROW  = 0,
    GROVE   = 1,
    VEIN    = 2,
    POND    = 3,
    COAST   = 4,
    REARING = 5,
}

xi.mog_garden.MAX_RANK = 7

-- Every family the vendors stock, in the order they list them. Monster rearing is the
-- sixth; the five before it are what the client calls the geological locations.
xi.mog_garden.shopLocations =
{
    xi.mog_garden.location.FURROW,
    xi.mog_garden.location.GROVE,
    xi.mog_garden.location.VEIN,
    xi.mog_garden.location.POND,
    xi.mog_garden.location.COAST,
    xi.mog_garden.location.REARING,
}

-- The five the client calls geological locations. Monster rearing is deliberately out:
-- bg-wiki's Titillating Tomes walkthrough spells out that its gate is "Rank 7 in all
-- geological locations (that is, you have bought the MHMU treatises for all sections of
-- your Mog Garden except monster rearing)".
xi.mog_garden.geologicalLocations =
{
    xi.mog_garden.location.FURROW,
    xi.mog_garden.location.GROVE,
    xi.mog_garden.location.VEIN,
    xi.mog_garden.location.POND,
    xi.mog_garden.location.COAST,
}
