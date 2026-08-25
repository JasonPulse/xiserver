-----------------------------------
-- Mog Garden rank book vendors
--
-- Zenicca in Western Adoulin sells the rank books for bayld; a Skipper Moogle in each
-- of the three ports sells the same books for gil, dearer. Shared here because the
-- four NPCs differ only in currency, event id, menu tree and which zone's text table
-- they draw their messages from.
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS AND CONFIRMED LIVE
--
--   Zenicca        Western Adoulin, entity 17826131, csid 7502
--   Skipper Moogle Port San d'Oria,  entity 17727657, csid 809
--   Skipper Moogle Port Bastok,      entity 17744187, csid 441
--   Skipper Moogle Port Windurst,    entity 17760509, csid 897
--
-- Each is the only substantial event on its entity, and each one's event data table
-- fingerprints the shop exactly. The three Skipper tables are identical: the six gil
-- prices 10000 / 20000 / 40000 / 80000 / 160000 / 320000, the six purchase thresholds
-- per family, then the thirty rank books in family-major rank-minor order followed by
-- the six monster rearing books. Zenicca's table carries the six bayld prices 1000 to
-- 11000 and key items 2412 to 2446 contiguously.
--
-- 809 was fired at the puppet in Port San d'Oria and rendered message 11799, "Heigh-ho,
-- kupo! I'm the boatswain for this darned-good dinghy...", so the csid is confirmed and
-- not merely fingerprinted. The 0x034 that came back also proved the params arrive in
-- the order passed below, with param 0 the nation index the program branches on.
--
-- THE MENU TREES, recovered from Selection Dialog text (the martello method)
--
-- Skipper Moogle, in the port's own dialog table:
--   11799  greeting, "what kind of cognition are you craving?"
--   11800  TOP    0 Nothing | 1 What Mog Gardens are | 2 How to get to one |
--                 3 What Mog Garden books are available   <- the shop
--   11801  "We've got staggering stores of the following scholarly scripts"
--   11802  LIST   0 None | 1..N one row per book on offer, names from params
--   11803  detail, "that one is reported to raise the rank of your
--          [furrows/arboreal grove/mineral vein/pond dredger/coastal fishing net/
--          monster rearing skills]...for the small sum of <n> gil"
--   11804  CONFIRM 0 Yes | 1 No
--   11805  bought, 11806 not experienced enough, 11807 nothing in stock
--
-- Zenicca uses the SHARED Adoulin bayld-vendor tree in zone 256's table, which is why
-- bg-wiki notes she explains nothing while the Skipper describes each book:
--   12040  greeting, 12027 LIST (row prices in params 17+), 12031 detail,
--   12032  CONFIRM 0 Yes | 1 No
--
-- 11803's family list is furrows / arboreal grove / mineral vein / pond dredger /
-- coastal fishing net / monster rearing, the THIRD independent confirmation of the
-- family order, after the shop data tables and the client's own rank menu (7556).
--
-- WHAT IS STILL NOT DECODED, and why this is built the way it is
--
-- Two things, both needing a live click that only a deployed build can log.
--
-- 1. Which bits of the 0x05B option carry the selected row. The two working shops of
--    this family in this repo disagree, so there is no universal answer to copy:
--      eschan_hub.lua  action = option & 0xFF, row = (option >> 8) & 0xFF
--      sparkshop.lua   category = option & 0xFF, selection = option >> 16
--    Both agree the low byte is the menu/action code and the row sits higher up, and
--    both handle it in onEventUpdate with the event held open. This follows that shape
--    and reads the row from either field.
--
-- 2. Which updateEvent query wants which parameter slots. Zenicca's 12027 puts row
--    prices in params 17 and up, past the eight startEvent can carry, so the client
--    assembles the list from several update replies. eschan_hub needed a dedicated
--    live calibration harness to crack the same problem; this is that size of job and
--    it is not done. Until it is, the list may render with blank or wrong prices.
--
-- WHY A MIS-DECODE IS STILL SAFE. The server builds the offer list itself, in family
-- order, and only ever puts a book on it that the player has already earned and can
-- reach. Row N therefore means "the Nth thing I was willing to sell you". A wrong row
-- field can only pick a different EARNED book, never an unearned one, never a rank out
-- of sequence, and never something unaffordable, because buyRankBook re-checks all
-- three. The print() below is what turns one live purchase into the final answer.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.mog_garden = xi.mog_garden or {}
xi.mog_garden.vendor = xi.mog_garden.vendor or {}

-- xi.mog_garden.location and xi.mog_garden.shopLocations come from
-- scripts/enum/mog_garden.lua, which is loaded before any global. They cannot be
-- declared in scripts/globals/mog_garden.lua: the globals walk is sorted as
-- std::set<std::filesystem::path>, which compares path components, so
-- 'globals/mog_garden' sorts before 'globals/mog_garden.lua' and THIS FILE RUNS
-- FIRST. Reading them off the parent at load time gets nil and takes the whole
-- module down with it, because a throwing require aborts the requiring file.

-- Nation index the Skipper Moogle's event program branches on, keyed by zone.
xi.mog_garden.vendor.nation =
{
    [xi.zone.PORT_SAN_DORIA] = 1,
    [xi.zone.PORT_BASTOK]    = 2,
    [xi.zone.PORT_WINDURST]  = 3,
}

-- Edification rank the Pioneers' Coalition needs before Zenicca is on her pitch at
-- all. FFXIclopedia: "Only present when the Pioneers' Coalition has an Edification
-- Rank 4 or higher."
xi.mog_garden.vendor.ZENICCA_EDIFICATION_RANK = 4

-- Row of the Skipper's top menu (11800) that opens the book list.
local skipperShopRow = 3

-- Row of a confirm menu (11804 / 12032) that means yes.
local confirmYesRow = 0

local stageTop     = 0
local stageList    = 1
local stageConfirm = 2

local stageVar = 'MogGardenShopStage'
local rowVar   = 'MogGardenShopRow'
local lastVar  = 'MogGardenShopLast'

-- The client's paging flag, same bit eschan_hub tests. Both book lists are "None." plus
-- sixteen rows plus "Previous page." and "Next page.", so a long list arrives a page at
-- a time and the row the client reports is page-relative.
--
-- This shop never pages, by construction rather than by luck: the offer list holds at
-- most one book per family, six in total, because the rank ladder is strictly
-- sequential and only the next rank of each family is ever for sale. Six rows fit on
-- page one, so page-relative and absolute rows are the same number. A page request is
-- therefore nothing to act on.
local pageRequestBit = 0x40000000

--- The books this player can be sold right now, in the order the shop lists them.
--- One per family at most, because the ladder is strictly sequential.
---@param player CBaseEntity
---@return table[] list of { location, rank, keyItem, bayld, gil }
xi.mog_garden.vendor.offers = function(player)
    local out = {}

    for _, location in ipairs(xi.mog_garden.shopLocations) do
        local keyItem, rank = xi.mog_garden.nextRankBook(player, location)
        if
            keyItem and
            xi.mog_garden.canBuyNextRank(player, location)
        then
            local bayld, gil = xi.mog_garden.nextRankCost(player, location)
            table.insert(out, { location = location, rank = rank, keyItem = keyItem, bayld = bayld, gil = gil })
        end
    end

    return out
end

-- The row field is one of these two. See the header: the two working shops of this
-- family in this repo put it in different places, so both are read and the first that
-- lands inside the offer list wins.
local function rowCandidates(option)
    return
    {
        bit.band(bit.rshift(option, 8), 0xFF),
        bit.band(bit.rshift(option, 16), 0xFF),
    }
end

local function menuCode(option)
    return bit.band(option, 0xFF)
end

--- Params the shop is opened with: the purse, then the rank of each of the six
--- families in the client's own menu order.
---@param player CBaseEntity
---@param currency string
---@return integer, integer, integer, integer, integer, integer, integer
xi.mog_garden.vendor.eventParams = function(player, currency)
    local purse = currency == 'bayld' and player:getCurrency('bayld') or player:getGil()

    return purse,
        xi.mog_garden.locationRank(player, xi.mog_garden.location.FURROW),
        xi.mog_garden.locationRank(player, xi.mog_garden.location.GROVE),
        xi.mog_garden.locationRank(player, xi.mog_garden.location.VEIN),
        xi.mog_garden.locationRank(player, xi.mog_garden.location.POND),
        xi.mog_garden.locationRank(player, xi.mog_garden.location.COAST),
        xi.mog_garden.locationRank(player, xi.mog_garden.location.REARING)
end

--- Open the shop. Resets the navigation stage so a reopened event starts at the top.
---@param player CBaseEntity
xi.mog_garden.vendor.onTrigger = function(player)
    player:setLocalVar(stageVar, stageTop)
    player:setLocalVar(rowVar, 0)
    player:setLocalVar(lastVar, 0)
end

--- Answer one menu yield. The event is held open so the player keeps shopping; only
--- the client ever closes it.
--- Purchases happen here rather than in onEventFinish because that is how this widget
--- family works: the client owns the menu tree and drives navigation from its own
--- bytecode, yielding to the server at each step. Both working shops of this family in
--- this repo (eschan_hub, sparkshop) transact in onEventUpdate for the same reason.
---@param player CBaseEntity
---@param option integer
---@param currency string 'bayld' or 'gil'
---@param isSkipper boolean true for the port moogles, false for Zenicca
xi.mog_garden.vendor.onEventUpdate = function(player, option, currency, isSkipper)
    -- Kept deliberately: one live purchase in the log pins the row field for good, and
    -- eschan_hub carries the same line for the same reason.
    print(string.format('[mogGardenShop] %s option %d (0x%X) stage %d',
        player:getName(), option, option, player:getLocalVar(stageVar)))

    -- A pick can arrive here and then echo in onEventFinish, and this debits currency,
    -- so the same option is only ever acted on once per step.
    if player:getLocalVar(lastVar) == option then
        return
    end

    player:setLocalVar(lastVar, option)

    if bit.band(option, pageRequestBit) ~= 0 then
        return
    end

    local offers = xi.mog_garden.vendor.offers(player)
    local stage  = player:getLocalVar(stageVar)

    if stage == stageTop then
        -- Zenicca has no explanations to branch into, so anything but the shop row on
        -- the Skipper's top menu is left alone and the client keeps navigating.
        if
            isSkipper and
            menuCode(option) ~= skipperShopRow
        then
            return
        end

        player:setLocalVar(stageVar, stageList)

        return
    end

    if stage == stageList then
        for _, row in ipairs(rowCandidates(option)) do
            if offers[row] then
                player:setLocalVar(rowVar, row)
                player:setLocalVar(stageVar, stageConfirm)

                return
            end
        end

        -- Row 0 is "None" on both lists, and an unrecognised row is treated the same
        -- way: stay put rather than guess at a book.
        return
    end

    if stage == stageConfirm then
        player:setLocalVar(stageVar, stageTop)

        if menuCode(option) ~= confirmYesRow then
            return
        end

        local offer = offers[player:getLocalVar(rowVar)]
        if not offer then
            return
        end

        xi.mog_garden.buyRankBook(player, offer.location, currency)
    end
end

--- A confirm that closes the event arrives here instead of in onEventUpdate, so it is
--- routed through the same handler; the last-option guard keeps a pick that shows up in
--- both from being charged twice.
---@param player CBaseEntity
---@param option integer
---@param currency string 'bayld' or 'gil'
---@param isSkipper boolean
xi.mog_garden.vendor.onEventFinish = function(player, option, currency, isSkipper)
    xi.mog_garden.vendor.onEventUpdate(player, option, currency, isSkipper)

    player:setLocalVar(stageVar, stageTop)
    player:setLocalVar(rowVar, 0)
    player:setLocalVar(lastVar, 0)
end
