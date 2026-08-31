-----------------------------------
-- Mog Garden Global
--
-- Retail's Mog Garden has five "geological locations" (the client's own term, see the
-- Mog Gardens Navigation template on bg-wiki), each ranked 1 to 7. Rank governs how
-- many gathering points exist, which drop lists are in play, and how many furrows can
-- be sown. Rank is raised by buying a book from Zenicca in Western Adoulin for bayld
-- or from a Skipper Moogle in one of the three ports for gil.
--
-- WHERE THE RANK-TO-BOOK MAPPING COMES FROM
--
-- Decoded from our own client DAT dumps, not copied from a wiki or another server.
-- The Skipper Moogle's event program carries its shop contents in the event data
-- table, and all three ports agree: six gil prices (10000, 20000, 40000, 80000,
-- 160000, 320000) followed by exactly thirty key items, in family-major rank-minor
-- order. Those thirty are the rank books.
--
-- This matters because the key item blocks are SEVEN wide, not six. Zenicca's program
-- carries 2412 through 2446 contiguously, seven per location. The seventh id of each
-- block (2418, 2425, 2432, 2439, 2446) is absent from every Skipper Moogle table and
-- is not a rank book at all. Reading rank as "index within the seven-wide block" would
-- mis-gate every location; rank is the index of the SELLABLE id within its block, plus
-- two, because a fresh garden is already rank 1.
--
-- The location ids, MAX_RANK and the two family orderings live in
-- scripts/enum/mog_garden.lua, not here, because the children of
-- scripts/globals/mog_garden/ execute BEFORE this file and need them at load time.
-- That file also records the three independent sources for the family order.
-- Monster rearing is the sixth family, and scripts/globals/monster_rearing.lua is
-- what spends its rank.
--
-- The purchase prerequisite counters are the client's too. Dialog 7545 and 7546 read
-- back "You have gathered from your furrow <n> times / grove <n> / veins <n>" and
-- "You have fished from the pond <n> times / coast <n>", which are exactly the five
-- lifetime tallies the shop thresholds compare against.
-----------------------------------
require('scripts/globals/mog_garden/yields')
require('scripts/globals/mog_garden/vendor')
require('scripts/globals/monster_rearing')
require('scripts/globals/npc_util')
-----------------------------------
local ID = zones[xi.zone.MOG_GARDEN]
-----------------------------------
xi = xi or {}
xi.mog_garden = xi.mog_garden or {}

-- Six books per location, ranks 2 through 7 in order.
local rankBooks =
{
    [xi.mog_garden.location.FURROW] =
    {
        xi.ki.SOW_YOUR_SEED,
        xi.ki.MY_FIRST_FURROW,
        xi.ki.FIELDS_AND_FERTILIZING,
        xi.ki.DESIGNER_FARMING,
        xi.ki.HOMESTEADERS_COMPENDIUM,
        xi.ki.MHMU_TREATISE_ON_AGRONOMY,
    },

    [xi.mog_garden.location.GROVE] =
    {
        xi.ki.GIVE_MY_REGARDS_TO_REODOAN,
        xi.ki.ADOULINS_TOPIARY_TREASURES,
        xi.ki.GRANDILOQUENT_GROVES,
        xi.ki.ARBOREAL_ABRACADABRA,
        xi.ki.VERDANT_AND_VERDONTS,
        xi.ki.MHMU_TREATISE_ON_FORESTRY,
    },

    [xi.mog_garden.location.VEIN] =
    {
        xi.ki.MYTHRIL_MARATHON_QUARTERLY,
        xi.ki.TAKE_A_LODE_OFF,
        xi.ki.VARICOSE_MINERAL_VEINS,
        xi.ki.TALES_FROM_THE_TUNNEL,
        xi.ki.THE_GUSGEN_MINES_TRAGEDY,
        xi.ki.MHMU_TREATISE_ON_MINERALS,
    },

    [xi.mog_garden.location.POND] =
    {
        xi.ki.A_FAREWELL_TO_FRESHWATER,
        xi.ki.WATER_WATER_EVERYWHERE,
        xi.ki.DREDGINGS_NO_DRUDGERY,
        xi.ki.ALL_THE_WAYS_TO_SKIN_A_CARP,
        xi.ki.ANATOMY_OF_AN_ANGLER,
        xi.ki.MHMU_TREATISE_ON_FISH_I,
    },

    [xi.mog_garden.location.COAST] =
    {
        xi.ki.THE_OLD_MEN_OF_THE_SEA,
        xi.ki.SUSUROONS_BIIIG_CATCH,
        xi.ki.BLACK_FISH_OF_THE_FAMILY,
        xi.ki.TWENTY_THOUSAND_YALMS_UNDER_THE_SEA,
        xi.ki.ENCYCLOPEDIA_ICTHYONNICA,
        xi.ki.MHMU_TREATISE_ON_FISH_II,
    },

    -- Monster rearing is the sixth family the shop tables carry, which is why the
    -- vendor's selection index runs to 36 rather than 30. bg-wiki names the six
    -- Sakura books and the rank each grants; monster_rearing.lua reads the rank
    -- back out of locationRank.
    [xi.mog_garden.location.REARING] =
    {
        xi.ki.SAKURA_AND_THE_MAGIC_SPOON,
        xi.ki.SAKURA_AND_THE_FOUNTAIN,
        xi.ki.SAKURA_AND_THE_MAGICKED_NET,
        xi.ki.SAKURAS_EXCELLENT_ADVENTURE,
        xi.ki.SAKURA_AND_THE_CACTUS_CORPS,
        xi.ki.SAKURA_AND_THE_HOLY_GRAIL,
    },
}

-- Purchase prerequisites, ranks 2 through 7. Read straight out of the Skipper Moogle
-- event data table, which lists them next to the prices it charges. The client is the
-- tiebreak where the wikis disagree, and it does disagree twice: bg-wiki puts the rank
-- 4 furrow gate at 50 harvests and the rank 4 grove and vein gate at 75 gathers, while
-- the client says 46 and 74.
local purchaseThresholds =
{
    [xi.mog_garden.location.FURROW] = { 4, 10, 46, 127, 256, 512 },
    [xi.mog_garden.location.GROVE]  = { 9, 20, 74, 195, 300, 750 },
    [xi.mog_garden.location.VEIN]   = { 9, 20, 74, 195, 300, 750 },
    [xi.mog_garden.location.POND]   = { 3, 7, 16, 29, 50, 80 },
    [xi.mog_garden.location.COAST]  = { 3, 7, 16, 29, 50, 80 },

    -- "Care for creatures <n> times", the wording on every Sakura book's own
    -- purchase note. Only interactions count; feeding and collecting do not.
    [xi.mog_garden.location.REARING] = { 15, 20, 40, 60, 80, 100 },
}

-- Ranks 2 through 7. Zenicca charges bayld, the Skipper Moogles charge gil.
local bayldCosts = { 1000, 3000, 5000, 7000, 9000, 11000 }
local gilCosts   = { 10000, 20000, 40000, 80000, 160000, 320000 }

-- Lifetime interaction tallies, the counters dialog 7545 and 7546 read back.
local interactionVars =
{
    [xi.mog_garden.location.FURROW] = 'Mog_Garden_Furrow_Gathers',
    [xi.mog_garden.location.GROVE]  = 'Mog_Garden_Grove_Gathers',
    [xi.mog_garden.location.VEIN]   = 'Mog_Garden_Vein_Gathers',
    [xi.mog_garden.location.POND]   = 'Mog_Garden_Pond_Fishings',
    [xi.mog_garden.location.COAST]  = 'Mog_Garden_Coast_Fishings',
    [xi.mog_garden.location.REARING] = 'Mog_Garden_Rearing_Cares',
}

local visitCountVar = 'Mog_Garden_Visit_Days'
local visitDayVar   = 'Mog_Garden_Visit_Last'
local secondsPerDay = 86400
local secondsPerHour = 3600

local function earthDay()
    return math.floor(GetSystemTime() / secondsPerDay)
end

-- Rank API ─────────────────────────────────────────────────────────────────

--- Current rank of one location, 1 to 7. A fresh garden is rank 1 everywhere.
--- The books are counted contiguously from rank 2 rather than tallied, so a key item
--- handed out of order (a GM grant, say) cannot skip a rank it has not paid for.
---@param player CBaseEntity
---@param location integer one of xi.mog_garden.location
---@return integer
xi.mog_garden.locationRank = function(player, location)
    local books = rankBooks[location]
    if not books then
        return 0
    end

    local rank = 1
    for _, keyItem in ipairs(books) do
        if not player:hasKeyItem(keyItem) then
            break
        end

        rank = rank + 1
    end

    return rank
end

--- True once every geological location is rank 7. This is Titillating Tomes' gate.
---@param player CBaseEntity
---@return boolean
xi.mog_garden.allLocationsMaxRank = function(player)
    for _, location in ipairs(xi.mog_garden.geologicalLocations) do
        if xi.mog_garden.locationRank(player, location) < xi.mog_garden.MAX_RANK then
            return false
        end
    end

    return true
end

--- How many times this player has ever worked one location.
---@param player CBaseEntity
---@param location integer
---@return integer
xi.mog_garden.interactionCount = function(player, location)
    local var = interactionVars[location]
    if not var then
        return 0
    end

    return player:getCharVar(var)
end

local function recordInteraction(player, location, times)
    local var = interactionVars[location]
    if not var then
        return
    end

    player:setCharVar(var, player:getCharVar(var) + times)
end

--- Record work at a location from outside this file. Monster rearing lives in its
--- own module but counts towards the same lifetime tally the shop reads.
---@param player CBaseEntity
---@param location integer
---@param times integer
---@return nil
xi.mog_garden.recordInteraction = function(player, location, times)
    recordInteraction(player, location, times)
end

--- How many separate Earth days this player has entered their Mog Garden.
---@param player CBaseEntity
---@return integer
xi.mog_garden.visitDays = function(player)
    return player:getCharVar(visitCountVar)
end

-- Male races, keyed by xi.race. Mithra and Galka are single gender, which is why
-- this is a lookup rather than the parity of the race id.
local maleRaces =
{
    [xi.race.HUME_M]   = true,
    [xi.race.ELVAAN_M] = true,
    [xi.race.TARU_M]   = true,
    [xi.race.GALKA]    = true,
}

--- Pick the right half of a gendered armour pair. Three Mog Garden quests pay out
--- kit that bg-wiki describes as "same as your character's gender": Titillating
--- Tomes' Straw Hat, Doctor Chacharoon's Work Gloves and Rowing Together's Thatch
--- Boots, each of which is two item ids in scripts/enum/item.lua.
---
--- This reads xi.race rather than player:getGender() deliberately. The binding
--- exists, but scripts/specs/core/CBaseEntity.lua annotates its return as a bare
--- `integer` with no encoding, and nothing in scripts/ documents which value means
--- which. Race IS enumerated here, and it settles the question outright, so the
--- mapping above cannot silently hand out the wrong half.
---@param player CBaseEntity
---@param maleItem integer
---@param femaleItem integer
---@return integer
xi.mog_garden.genderedReward = function(player, maleItem, femaleItem)
    if maleRaces[player:getRace()] then
        return maleItem
    end

    return femaleItem
end

-- Purchasing ───────────────────────────────────────────────────────────────

--- The book that would raise one location by a rank, or nil at rank 7.
---@param player CBaseEntity
---@param location integer
---@return integer|nil keyItem
---@return integer|nil rank the rank that book grants
xi.mog_garden.nextRankBook = function(player, location)
    local books = rankBooks[location]
    if not books then
        return nil, nil
    end

    local rank = xi.mog_garden.locationRank(player, location)
    if rank >= xi.mog_garden.MAX_RANK then
        return nil, nil
    end

    return books[rank], rank + 1
end

--- What one location's next book costs, in bayld and in gil.
---@param player CBaseEntity
---@param location integer
---@return integer bayld 0 when there is nothing left to buy
---@return integer gil
xi.mog_garden.nextRankCost = function(player, location)
    local _, rank = xi.mog_garden.nextRankBook(player, location)
    if not rank then
        return 0, 0
    end

    return bayldCosts[rank - 1], gilCosts[rank - 1]
end

--- Whether the player has worked this location often enough to be sold its next book.
---@param player CBaseEntity
---@param location integer
---@return boolean
xi.mog_garden.canBuyNextRank = function(player, location)
    local _, rank = xi.mog_garden.nextRankBook(player, location)
    if not rank then
        return false
    end

    local thresholds = purchaseThresholds[location]
    if not thresholds then
        return false
    end

    return xi.mog_garden.interactionCount(player, location) >= thresholds[rank - 1]
end

--- Sell one location's next rank book.
--- Retail refuses on three counts, in this order: the location is already rank 7, the
--- player has not worked it enough times yet, or the player cannot afford it. Nothing
--- is debited unless the key item is actually handed over.
---@param player CBaseEntity
---@param location integer
---@param currency string 'bayld' or 'gil'
---@return boolean sold
xi.mog_garden.buyRankBook = function(player, location, currency)
    local keyItem = xi.mog_garden.nextRankBook(player, location)
    if not keyItem then
        return false
    end

    if not xi.mog_garden.canBuyNextRank(player, location) then
        return false
    end

    local bayld, gil = xi.mog_garden.nextRankCost(player, location)

    if currency == 'bayld' then
        if player:getCurrency('bayld') < bayld then
            return false
        end

        player:delCurrency('bayld', bayld)
    else
        if player:getGil() < gil then
            return false
        end

        player:delGil(gil)
    end

    npcUtil.giveKeyItem(player, keyItem)

    -- 7557 "The [furrows are/grove is/vein is/pond is/coast is/M is] now rank <n>."
    -- lives in the Mog Garden dialog table, not the vendor's zone, so the confirmation
    -- the shop can actually render is the key item line npcUtil already sends.
    return true
end

-- Gathering nodes ──────────────────────────────────────────────────────────
--
-- Grove and vein each have four rank tiers, and each tier is a PAIR of entities: one
-- per gathering action. bg-wiki pins which is which for the vein ("The node for
-- precious metal ores is always the higher node") and npc_list.sql agrees, listing
-- each pair as the lower entity then the higher one (y is inverted in Vana'diel, so
-- the second of each pair, at the more negative y, is the one above). The grove splits
-- the same way, the tree for pruning and the ground for weeding.
--
-- Tier 4 of the grove is the one pair with no height split, because rank 7 adds a
-- deciduous fern rather than a tree, so it keeps tiers 1 to 3's first-is-pruning order.
local nodeActions =
{
    [xi.mog_garden.location.GROVE] = { 'prune', 'weeds' },
    [xi.mog_garden.location.VEIN]  = { 'metals', 'precious' },
}

local nodeBases =
{
    [xi.mog_garden.location.GROVE] = ID.npc.ARBOREAL_GROVE,
    [xi.mog_garden.location.VEIN]  = ID.npc.MINERAL_VEIN,
}

local yieldTableNames =
{
    [xi.mog_garden.location.GROVE] = 'grove',
    [xi.mog_garden.location.VEIN]  = 'vein',
}

-- Rank a tier needs before it exists at all, and the highest rank list it draws from.
-- Both wikis give the same picture: tier 2 appears at rank 3, tier 3 at rank 5, tier 4
-- at rank 7, and a tier only ever yields items up to its own bracket. That is why
-- bg-wiki tells you to mine vein #4 for a Philosopher's Stone and nothing else will do.
local tierUnlockRank = { 1, 3, 5, 7 }
local tierRankCap    = { 2, 4, 6, 7 }

-- Attempts each grove or vein node allows per Earth day.
--
-- The client reports the remainder ("You can harvest from it <n> more times", Mog
-- Garden dialog 7364 and 7379) but the budget itself is server side and neither wiki
-- publishes it. Three is the figure the data pins down in the one case with no
-- assistant, serum or fertilizer muddying it: rank 2 costs 9 gathers, which the client
-- shop table states outright, and FFXIclopedia measures that as "3 fully cleared days"
-- at rank 1, when a single node exists. 9 / 3 = 3. The later ranks come in faster than
-- three a day predicts, which is expected, since by then players have the assistants
-- and the free-attempt serums that FFXIclopedia says its day counts assume away.
local attemptsPerNode = 3

-- Items one gather hands over. "1-3 items, randomly chosen from the Metals +
-- Biominerals lists or the Precious metals + Biominerals lists", on both wikis.
local minItemsPerGather = 1
local maxItemsPerGather = 3

-- Daily use counts are packed into one CharVar per family, three bits per node, so
-- eight nodes fit inside a signed 32-bit value with room over. char_vars.varname is
-- varchar(30), which is why the names are terse.
local usesBitsPerNode = 3
local usesNodeMask    = 7

local dailyVars =
{
    [xi.mog_garden.location.GROVE] = { day = 'Mog_Garden_Grove_Day', uses = 'Mog_Garden_Grove_Uses' },
    [xi.mog_garden.location.VEIN]  = { day = 'Mog_Garden_Vein_Day', uses = 'Mog_Garden_Vein_Uses' },
}

local function dailyUses(player, location)
    local vars = dailyVars[location]
    if player:getCharVar(vars.day) ~= earthDay() then
        return 0
    end

    return player:getCharVar(vars.uses)
end

local function nodeUses(packed, nodeIndex)
    return bit.band(bit.rshift(packed, nodeIndex * usesBitsPerNode), usesNodeMask)
end

local function recordNodeUse(player, location, nodeIndex, packed)
    local vars  = dailyVars[location]
    local used  = nodeUses(packed, nodeIndex)
    local shift = nodeIndex * usesBitsPerNode

    local cleared = bit.band(packed, bit.bnot(bit.lshift(usesNodeMask, shift)))
    local updated = bit.bor(cleared, bit.lshift(used + 1, shift))

    player:setCharVar(vars.day, earthDay())
    player:setCharVar(vars.uses, updated)
end

--- Which family, tier and action a grove or vein entity is.
---@param npc CBaseEntity
---@return integer|nil location
---@return integer|nil tier 1 to 4
---@return string|nil action key into the yield table
local function classifyNode(npc)
    local npcId = npc:getID()

    for location, base in pairs(nodeBases) do
        local offset = npcId - base
        if
            offset >= 0 and
            offset < #tierUnlockRank * 2
        then
            local tier   = math.floor(offset / 2) + 1
            local action = nodeActions[location][offset % 2 + 1]

            return location, tier, action
        end
    end

    return nil, nil, nil
end

--- Everything a tier can drop for one action at the player's current rank.
local function gatherPoolFor(location, tier, rank, action)
    local byRank = xi.mog_garden.yields[yieldTableNames[location]]
    local pool   = {}

    local top = math.min(tierRankCap[tier], rank)
    for listRank = 1, top do
        local lists = byRank[listRank]
        for _, itemId in ipairs(lists[action] or {}) do
            table.insert(pool, itemId)
        end
    end

    -- The vein's biominerals column is shared by both mining nodes.
    if location == xi.mog_garden.location.VEIN then
        for listRank = 1, top do
            for _, itemId in ipairs(byRank[listRank].either or {}) do
                table.insert(pool, itemId)
            end
        end
    end

    return pool
end

local function handOverGather(player, pool)
    local wanted = math.random(minItemsPerGather, maxItemsPerGather)
    local given  = 0

    for _ = 1, wanted do
        local itemId = pool[math.random(#pool)]
        if not npcUtil.giveItem(player, itemId) then
            break
        end

        given = given + 1
    end

    return given
end

local function groveOrVeinOnTrigger(player, npc, location, tier, action)
    local rank = xi.mog_garden.locationRank(player, location)
    local isVein = location == xi.mog_garden.location.VEIN

    if rank < tierUnlockRank[tier] then
        player:messageSpecial(isVein and ID.text.VEIN_MIN_RANK or ID.text.GROVE_MIN_RANK, tierUnlockRank[tier])

        return
    end

    local nodeIndex = (tier - 1) * 2 + (action == nodeActions[location][1] and 0 or 1)
    local packed    = dailyUses(player, location)
    local used      = nodeUses(packed, nodeIndex)

    if used >= attemptsPerNode then
        player:messageSpecial(isVein and ID.text.VEIN_BEST_TO_STOP or ID.text.GROVE_NOTHING_TO_DO)

        return
    end

    local pool = gatherPoolFor(location, tier, rank, action)
    if #pool == 0 then
        return
    end

    if handOverGather(player, pool) == 0 then
        return
    end

    recordNodeUse(player, location, nodeIndex, packed)
    recordInteraction(player, location, 1)

    local remaining = attemptsPerNode - used - 1
    if remaining > 0 then
        player:messageSpecial(isVein and ID.text.VEIN_RANK_AND_USES or ID.text.GROVE_RANK_AND_USES, rank, 0, remaining)
    else
        player:messageSpecial(isVein and ID.text.VEIN_BEST_TO_STOP or ID.text.GROVE_NOTHING_TO_DO)
    end
end

-- Pond dredger and coastal fishing net ─────────────────────────────────────
--
-- "We've set two nets for you, which may each be brought up only once per day (Earth
-- time)" (Mog Garden dialog 7506), yielding eight items. From rank 6 the normal pool
-- stops growing at the rank 4 lists and catch slots 4 and 8 draw from a separate
-- rarer list instead. Rank 7's special list is what makes a Drill Calamary and a
-- Calico Comet reachable with no bait and no assistant, which is what Titillating
-- Tomes needs.
local netCatchCount    = 8
local netSpecialRank   = 6
local netNormalCapRank = 4
local netSpecialSlots  = { [4] = true, [8] = true }

local netConfig =
{
    [xi.mog_garden.location.POND] =
    {
        yieldTable = 'pond',
        dayVar     = 'Mog_Garden_Pond_Day',
        rankText   = 'POND_RANK',
    },

    [xi.mog_garden.location.COAST] =
    {
        yieldTable = 'coast',
        dayVar     = 'Mog_Garden_Coast_Day',
        rankText   = 'COAST_RANK',
    },
}

local function netPools(location, rank)
    local lists  = xi.mog_garden.yields[netConfig[location].yieldTable]
    local normal = {}

    local top = rank >= netSpecialRank and netNormalCapRank or rank
    for listRank = 1, top do
        for _, itemId in ipairs(lists.normal[listRank] or {}) do
            table.insert(normal, itemId)
        end
    end

    return normal, lists.special[rank]
end

local function netOnTrigger(player, npc, location)
    local config = netConfig[location]
    local rank   = xi.mog_garden.locationRank(player, location)

    player:messageSpecial(ID.text[config.rankText], rank)

    if player:getCharVar(config.dayVar) == earthDay() then
        player:messageSpecial(ID.text.NET_TOO_LIGHT)

        return
    end

    local normal, special = netPools(location, rank)
    if #normal == 0 then
        return
    end

    -- Claim the day before handing anything over. A net that gives out part of a haul
    -- and then hits a full inventory has still been raised, which is retail: dialog
    -- 7400 "Make sure to take your catch home with you" and 7376 warn that anything
    -- you cannot carry is gone.
    player:setCharVar(config.dayVar, earthDay())
    recordInteraction(player, location, 1)

    for slot = 1, netCatchCount do
        local pool = normal
        if
            special and
            netSpecialSlots[slot]
        then
            pool = special
        end

        if not npcUtil.giveItem(player, pool[math.random(#pool)]) then
            break
        end
    end
end

-- Garden furrows ───────────────────────────────────────────────────────────
--
-- "As your garden grows in rank, you can claim higher quality crops with the same
-- seeds, kupo. The number of furrows will also fill out finely so you can sprout up to
-- three seeds" (Mog Garden dialog 7497). The plot unlocks are exact: bg-wiki's key
-- item table marks "My First Furrow" (rank 3) as unlocking the second row and
-- "Designer Farming" (rank 5) the third.
--
-- The quality half has no published per-rank table on either wiki, so rank scales the
-- harvest COUNT across the range bg-wiki documents for each seed: rank 1 yields the
-- low end, rank 7 the high end. That is stated here rather than dressed up as retail
-- data, because it is the one number in this file that is a reading rather than a
-- source.
--
-- Grow times are Earth hours, which is what both the wiki table and the client use
-- ("in about <n> hour[/s] and <n> minute[/s] (Earth time)", dialog 7340).
local plotSlotByNpcName =
{
    ['Garden_Furrow']    = 1,
    ['Garden_Furrow_#2'] = 2,
    ['Garden_Furrow_#3'] = 3,
}

local plotUnlockRank = { 1, 3, 5 }

local function plotVars(slot)
    return
        string.format('Mog_Garden_Plot%d_Seed', slot),
        string.format('Mog_Garden_Plot%d_Ripe', slot),
        string.format('Mog_Garden_Plot%d_Left', slot)
end

local function harvestCount(entry, rank)
    local span = entry.yieldMax - entry.yieldMin
    if span <= 0 then
        return entry.yieldMin
    end

    return entry.yieldMin + math.floor(span * (rank - 1) / (xi.mog_garden.MAX_RANK - 1))
end

xi.mog_garden.furrowOnTrade = function(player, npc, trade)
    local slot = plotSlotByNpcName[npc:getName()]
    if not slot then
        return
    end

    local rank = xi.mog_garden.locationRank(player, xi.mog_garden.location.FURROW)
    if rank < plotUnlockRank[slot] then
        player:messageSpecial(ID.text.FURROW_MIN_RANK, plotUnlockRank[slot])

        return
    end

    local seedVar, ripeVar, leftVar = plotVars(slot)
    if player:getCharVar(seedVar) ~= 0 then
        player:printToPlayer('This furrow is already sown. Harvest it before planting again.')

        return
    end

    local tradedItem = trade:getItemId()
    local entry      = xi.mog_garden.yields.furrow[tradedItem]
    if
        not entry or
        trade:getItemCount() ~= 1
    then
        return
    end

    player:confirmTrade()
    player:setCharVar(seedVar, tradedItem)
    player:setCharVar(ripeVar, GetSystemTime() + entry.hours * secondsPerHour)
    player:setCharVar(leftVar, entry.harvests)
    player:printToPlayer(string.format('Sown. The crop will be ready in about %d hour(s) of Earth time.', entry.hours))
end

xi.mog_garden.furrowOnTrigger = function(player, npc)
    local slot = plotSlotByNpcName[npc:getName()]
    if not slot then
        return
    end

    local rank = xi.mog_garden.locationRank(player, xi.mog_garden.location.FURROW)
    if rank < plotUnlockRank[slot] then
        player:messageSpecial(ID.text.FURROW_MIN_RANK, plotUnlockRank[slot])

        return
    end

    local seedVar, ripeVar, leftVar = plotVars(slot)
    local planted                   = player:getCharVar(seedVar)
    if planted == 0 then
        player:messageSpecial(ID.text.FURROW_EMPTY, rank)

        return
    end

    local entry = xi.mog_garden.yields.furrow[planted]
    if not entry then
        -- Seed no longer in the plantable table. Clear the plot rather than strand it.
        player:setCharVar(seedVar, 0)
        player:setCharVar(ripeVar, 0)
        player:setCharVar(leftVar, 0)

        return
    end

    local remainingSeconds = player:getCharVar(ripeVar) - GetSystemTime()
    if remainingSeconds > 0 then
        player:printToPlayer(string.format('The crop needs about %d more minute(s) of Earth time to ripen.',
            math.max(1, math.floor(remainingSeconds / 60))))

        return
    end

    local wanted = harvestCount(entry, rank)
    local given  = 0
    for _ = 1, wanted do
        if not npcUtil.giveItem(player, entry.pool[math.random(#entry.pool)]) then
            break
        end

        given = given + 1
    end

    if given == 0 then
        return
    end

    recordInteraction(player, xi.mog_garden.location.FURROW, 1)

    local harvestsLeft = player:getCharVar(leftVar) - 1
    if harvestsLeft > 0 then
        player:setCharVar(leftVar, harvestsLeft)
        player:setCharVar(ripeVar, GetSystemTime() + entry.hours * secondsPerHour)
    else
        player:setCharVar(seedVar, 0)
        player:setCharVar(ripeVar, 0)
        player:setCharVar(leftVar, 0)
    end
end

-- Flotsam ──────────────────────────────────────────────────────────────────
--
-- Flotsam is the one gathering point with no rank: "There's no key item to increase
-- Flotsam's rank" (bg-wiki, via Zenicca's notes). Retail washes something ashore once
-- a day, which is what this does.
local flotsamDayVar = 'Mog_Garden_Flotsam_Day'

local flotsamPool =
{
    xi.item.LAUAN_LOG,
    xi.item.BIBIKI_URCHIN,
    xi.item.QUUS_1,
}

local function flotsamOnTrigger(player)
    if player:getCharVar(flotsamDayVar) == earthDay() then
        player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)

        return
    end

    if npcUtil.giveItem(player, flotsamPool[math.random(#flotsamPool)]) then
        player:setCharVar(flotsamDayVar, earthDay())
    end
end

-- Node dispatch ────────────────────────────────────────────────────────────

--- Every gathering point in the zone funnels through here. The garden quests hook the
--- same NPCs and return nothing so their handler falls through to this, so the entry
--- point name has to stay put.
xi.mog_garden.nodeOnTrigger = function(player, npc)
    local name = npc:getName()

    -- bg-wiki: a creature that has succumbed to darkness "renders all Mog Garden
    -- gathering nodes inoperable, except the Flotsam node on the beach."
    if
        name ~= 'Flotsam' and
        xi.monsterRearing.nodesBlocked(player)
    then
        player:printToPlayer('Your creature\'s mood has soured the garden. Nothing will come up until it is calmed.', xi.msg.channel.NS_SAY)
        return
    end

    if name == 'Pond_Dredger' then
        return netOnTrigger(player, npc, xi.mog_garden.location.POND)
    end

    if name == 'Coastal_Fishing_Net' then
        return netOnTrigger(player, npc, xi.mog_garden.location.COAST)
    end

    if name == 'Flotsam' then
        return flotsamOnTrigger(player)
    end

    local location, tier, action = classifyNode(npc)
    if not location then
        return
    end

    return groveOrVeinOnTrigger(player, npc, location, tier, action)
end

-- Zone plumbing ────────────────────────────────────────────────────────────

-- NPC name prefixes / families that should stay hidden on zone load —
-- they're quest-specific or duplicate-state assistants tied to the retail
-- tutorial chain that we don't yet implement. Leaving them visible would
-- expose 100+ disabled NPCs with no scripts, which is worse than the prior
-- hide-all but better than the empty-zone failure mode that the hide-all
-- version produced when any GetNPCByID lookup returned nil and aborted
-- the rest of the show-default block.
local hiddenNpcPrefixes =
{
    '_7s',          -- staging/CS placeholders for retail tutorial chain
    'Plant',        -- garden plot plant states (no per-player tracking yet)
    'PlantFurn',    -- garden plot furniture states
    'KANI',         -- crab decorations
    'DIRECTOR',     -- camera placeholders
    'Breeding',     -- monster rearing slots
    'Goblin_Footprint', -- quest-specific spawn
    'blank',        -- internal placeholder
}

local function shouldHide(name)
    if not name or name == '' then
        return true -- nameless / 0x?? entity ids stay hidden
    end

    for _, prefix in ipairs(hiddenNpcPrefixes) do
        if name:sub(1, #prefix) == prefix then
            return true
        end
    end

    return false
end

xi.mog_garden.onInitialize = function(zone)
    local npcs = zone:getNPCs() or {}
    for _, npc in pairs(npcs) do
        if shouldHide(npc:getName()) then
            npc:setStatus(xi.status.DISAPPEAR)
        else
            -- Defensive NORMAL: in case the previous build left an NPC stuck
            -- on DISAPPEAR from the old hide-all path, restore it.
            npc:setStatus(xi.status.NORMAL)
        end
    end
end

-- GPS crystal stars. Retail lights one star per EARTH day the garden is entered,
-- and three quests gate on that running total: Courtesy Crustacean at 5, Trinket
-- for the Tyrant at 10, Hypnotic Hospitality at 20. bg-wiki is emphatic that these
-- are separate Earth days, and that Shining Stars handed out by a campaign do not
-- count, so the day comes from GetSystemTime rather than VanadielUniqueDay.
local function recordVisit(player)
    local today = earthDay()
    if player:getCharVar(visitDayVar) >= today then
        return
    end

    local total = player:getCharVar(visitCountVar) + 1

    player:setCharVar(visitDayVar, today)
    player:setCharVar(visitCountVar, total)

    -- The star lit today is also spendable. Monster Rearing pays shining stars for
    -- moogle magic and for changing a cheer, and char_points already carries the
    -- balance through to the client's currency list.
    player:addCurrency('shining_star', 1)

    -- 7515 reads "<n> star has come aglow. A total of <n> stars twinkle softly
    -- inside your <item>", numbered parameters 1 and 2, so parameter 0 is unused.
    if player:hasKeyItem(xi.ki.GPS_CRYSTAL) then
        player:messageSpecial(ID.text.STARS_ON_KEYITEM, 0, 1, total)
    end
end

xi.mog_garden.onZoneIn = function(player, prevZone)
    if
        not player or
        player:getZoneID() ~= xi.zone.MOG_GARDEN
    then
        return
    end

    -- Deferred because messageSpecial fired during onGameIn races the client's chat
    -- buffer init, so the star line never renders even though the count advances.
    player:timer(3000, function(p)
        recordVisit(p)
        xi.monsterRearing.onZoneIn(p)
    end)
end

xi.mog_garden.onTriggerAreaEnter = function(player, triggerArea)
end

xi.mog_garden.onEventUpdate = function(player, csid, option, npc)
end

xi.mog_garden.onEventFinish = function(player, csid, option, npc)
end
