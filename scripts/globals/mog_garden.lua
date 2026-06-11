-----------------------------------
-- Mog Garden Global
-----------------------------------
local ID = zones[xi.zone.MOG_GARDEN]
-----------------------------------
xi = xi or {}
xi.mog_garden = xi.mog_garden or {}

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

-- Simplified daily harvest. Retail's Mog Garden has a full plant-and-grow
-- gathering system + monster rearing + Bonanza minigame; none of that is
-- implemented. Until then, a once-per-Vana'diel-day zone-in claim gives
-- players a reason to visit and matches the spirit of "the garden produced
-- something today." Picks one item from each of three slots (vegetables /
-- fruits / grains / herbs / wildgrass) for variety.
local harvestPool =
{
    xi.item.SAN_DORIAN_CARROT,
    xi.item.SARUTA_ORANGE,
    xi.item.WOOZYSHROOM,
    xi.item.SLEEPSHROOM,
    xi.item.REISHI_MUSHROOM,
    xi.item.BOTTLE_OF_YAGUDO_DRINK,
    xi.item.JUG_OF_SELBINA_MILK,
    xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES,
    xi.item.BOX_OF_TARUTARU_RICE,
    xi.item.CLUMP_OF_MOKO_GRASS,
}

local dailyHarvestVar = 'Mog_Garden_Daily_Harvest'
local tutorialDoneVar = 'Mog_Garden_Tutorial_Done'

-- Starter pack for the first-visit tutorial bypass. Bit flags track which
-- seeds the player has already received so a full inventory on first visit
-- doesn't permanently skip the remaining seeds — the un-granted ones drop
-- on the next zone-in until the player has them all.
local tutorialSeedPack =
{
    { item = xi.item.BAG_OF_VEGETABLE_SEEDS, flag = 0x01 },
    { item = xi.item.BAG_OF_FRUIT_SEEDS,     flag = 0x02 },
    { item = xi.item.BAG_OF_GRAIN_SEEDS,     flag = 0x04 },
    { item = xi.item.BAG_OF_HERB_SEEDS,      flag = 0x08 },
    { item = xi.item.BAG_OF_WILDGRASS_SEEDS, flag = 0x10 },
    { item = xi.item.BAG_OF_FLOWER_SEEDS,    flag = 0x20 },
}

local tutorialCompleteMask = 0x3F -- 0b111111 — all 6 flags set

local function runTutorialBypass(player)
    local state = player:getCharVar(tutorialDoneVar)
    if state >= tutorialCompleteMask then
        return -- already complete
    end

    if state == 0 then
        player:printToPlayer('Welcome to your Mog Garden! Plant the seeds I\'ve given you in any Garden Furrow, and return after a Vana\'diel day or two to harvest.')
    end

    local newState = state
    for _, entry in ipairs(tutorialSeedPack) do
        if
            bit.band(newState, entry.flag) == 0 and
            npcUtil.giveItem(player, entry.item)
        then
            newState = bit.bor(newState, entry.flag)
        end

        -- If giveItem failed (full inventory) the flag stays unset and we
        -- retry that seed on the next zone-in.
    end

    if newState ~= state then
        player:setCharVar(tutorialDoneVar, newState)
    end
end

xi.mog_garden.onZoneIn = function(player, prevZone)
    if not player or player:getZoneID() ~= xi.zone.MOG_GARDEN then
        return
    end

    -- First-visit tutorial: drop the starter seed pack on the player. Run
    -- this BEFORE the daily harvest so a tutorial-complete player still
    -- gets their harvest on the same zone-in.
    runTutorialBypass(player)

    local today     = VanadielUniqueDay()
    local lastClaim = player:getCharVar(dailyHarvestVar)
    if lastClaim >= today then
        return
    end

    local item = harvestPool[math.random(#harvestPool)]
    if not item then
        return
    end

    if npcUtil.giveItem(player, item) then
        player:setCharVar(dailyHarvestVar, today)
        player:messageSpecial(ID.text.ITEM_OBTAINED, item)
    end
end

-- Garden plots ─────────────────────────────────────────────────────────────
-- Each player has up to 3 plots (Garden_Furrow / Garden_Furrow_#2 /
-- Garden_Furrow_#3). State is per-player via CharVars:
--   Mog_Garden_Plot_<n>_Seed — item id of the seed planted (0 = empty)
--   Mog_Garden_Plot_<n>_Day  — VanadielUniqueDay() of planting
-- Plot becomes harvestable after `daysToHarvest` Vana'diel days; trade the
-- corresponding seed bag to a furrow to plant; trigger when ripe to harvest.
local plotSlotByNpcName =
{
    ['Garden_Furrow']    = 1,
    ['Garden_Furrow_#2'] = 2,
    ['Garden_Furrow_#3'] = 3,
}

local seedYields =
{
    [xi.item.BAG_OF_VEGETABLE_SEEDS]  = { xi.item.SAN_DORIAN_CARROT,             xi.item.SARUTA_ORANGE },
    [xi.item.BAG_OF_FRUIT_SEEDS]      = { xi.item.SARUTA_ORANGE,                 xi.item.SARUTA_ORANGE },
    [xi.item.BAG_OF_GRAIN_SEEDS]      = { xi.item.BOX_OF_TARUTARU_RICE,          xi.item.CLUMP_OF_WINDURSTIAN_TEA_LEAVES },
    [xi.item.BAG_OF_HERB_SEEDS]       = { xi.item.WOOZYSHROOM,                   xi.item.SLEEPSHROOM, xi.item.REISHI_MUSHROOM },
    [xi.item.BAG_OF_WILDGRASS_SEEDS]  = { xi.item.CLUMP_OF_MOKO_GRASS,           xi.item.CLUMP_OF_MOKO_GRASS },
    [xi.item.BAG_OF_FLOWER_SEEDS]     = { xi.item.JUG_OF_SELBINA_MILK,           xi.item.BOTTLE_OF_YAGUDO_DRINK },
}

local daysToHarvest = 2

local function plotVars(slot)
    return
        string.format('Mog_Garden_Plot_%d_Seed', slot),
        string.format('Mog_Garden_Plot_%d_Day', slot)
end

xi.mog_garden.furrowOnTrade = function(player, npc, trade)
    local slot = plotSlotByNpcName[npc:getName()]
    if not slot then
        return
    end

    local seedVar, dayVar = plotVars(slot)
    if player:getCharVar(seedVar) ~= 0 then
        player:printToPlayer('This plot is already in use. Harvest before replanting.')
        return
    end

    local tradedItem = trade:getItemId()
    if not seedYields[tradedItem] or trade:getItemCount() ~= 1 then
        return
    end

    player:confirmTrade()
    player:setCharVar(seedVar, tradedItem)
    player:setCharVar(dayVar, VanadielUniqueDay())
    player:printToPlayer(string.format('Planted. Return in %d Vana\'diel day(s) to harvest.', daysToHarvest))
end

xi.mog_garden.furrowOnTrigger = function(player, npc)
    local slot = plotSlotByNpcName[npc:getName()]
    if not slot then
        return
    end

    local seedVar, dayVar = plotVars(slot)
    local planted         = player:getCharVar(seedVar)
    if planted == 0 then
        player:printToPlayer('The plot is empty. Trade a bag of seeds to plant.')
        return
    end

    local plantedDay = player:getCharVar(dayVar)
    local elapsed    = VanadielUniqueDay() - plantedDay
    if elapsed < daysToHarvest then
        local remaining = daysToHarvest - elapsed
        player:printToPlayer(string.format('The crop needs %d more Vana\'diel day(s) to ripen.', remaining))
        return
    end

    local yields = seedYields[planted]
    if not yields or #yields == 0 then
        -- Stale seed id (post-balance changes). Clear the plot so the player
        -- isn't stuck.
        player:setCharVar(seedVar, 0)
        player:setCharVar(dayVar, 0)
        return
    end

    local item = yields[math.random(#yields)]
    if npcUtil.giveItem(player, item) then
        player:setCharVar(seedVar, 0)
        player:setCharVar(dayVar, 0)
        player:messageSpecial(ID.text.ITEM_OBTAINED, item)
    end
end

-- Gathering nodes ──────────────────────────────────────────────────────────
-- Mog Garden has 5 gathering node families. Retail gives N uses per node-
-- family per Vana'diel day with random yields. We track uses via a single
-- CharVar per family (uses-and-day packed: uses * 1000 + day for cheap
-- single-var storage). The numbered NPC variants (e.g. Arboreal_Grove vs
-- Arboreal_Grove_#2) all share a family pool.
local nodeFamilies =
{
    -- prefix             max uses/day   yield pool
    Arboreal_Grove      = { 3, { xi.item.LAUAN_LOG, xi.item.HOLLY_LOG, xi.item.MAPLE_LOG, xi.item.WALNUT_LOG } },
    Mineral_Vein        = { 3, { xi.item.CHUNK_OF_IRON_ORE, xi.item.CHUNK_OF_COPPER_ORE, xi.item.CHUNK_OF_ZINC_ORE, xi.item.CHUNK_OF_TIN_ORE, xi.item.LAPIS_LAZULI } },
    Pond_Dredger        = { 3, { xi.item.QUUS_1, xi.item.CHEVAL_SALMON, xi.item.TRICOLORED_CARP, xi.item.COPPER_FROG_2 } },
    Coastal_Fishing_Net = { 3, { xi.item.BLUETAIL_1, xi.item.TIGER_COD_1, xi.item.BIBIKI_URCHIN } },
    Flotsam             = { 3, { xi.item.LAUAN_LOG, xi.item.BIBIKI_URCHIN, xi.item.QUUS_1 } },
}

-- Map any node display name to its family prefix.
local function familyFor(name)
    if not name then
        return nil
    end

    if nodeFamilies[name] then
        return name
    end

    -- Strip optional "_#N" suffix.
    local base = name:match('^(.-)_#%d+$')
    if base and nodeFamilies[base] then
        return base
    end

    return nil
end

local function familyVarFor(prefix)
    return 'Mog_Garden_Node_' .. prefix
end

xi.mog_garden.nodeOnTrigger = function(player, npc)
    local prefix = familyFor(npc:getName())
    if not prefix then
        return
    end

    local maxUses, yields = nodeFamilies[prefix][1], nodeFamilies[prefix][2]
    local var             = familyVarFor(prefix)
    local packed          = player:getCharVar(var)
    local today           = VanadielUniqueDay()
    local storedDay       = packed % 1000
    local storedUses      = math.floor(packed / 1000)

    if storedDay ~= today then
        storedUses = 0
    end

    if storedUses >= maxUses then
        player:printToPlayer(string.format('%s has nothing more to give today.', (prefix:gsub('_', ' '))))
        return
    end

    local item = yields[math.random(#yields)]
    if not item then
        return
    end

    if npcUtil.giveItem(player, item) then
        local newPacked = (storedUses + 1) * 1000 + today
        player:setCharVar(var, newPacked)
        player:messageSpecial(ID.text.ITEM_OBTAINED, item)
    end
end

xi.mog_garden.onTriggerAreaEnter = function(player, triggerArea)
end

xi.mog_garden.onEventUpdate = function(player, csid, option, npc)
end

xi.mog_garden.onEventFinish = function(player, csid, option, npc)
end
