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

xi.mog_garden.onZoneIn = function(player, prevZone)
    if not player or player:getZoneID() ~= xi.zone.MOG_GARDEN then
        return
    end

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

xi.mog_garden.onTriggerAreaEnter = function(player, triggerArea)
end

xi.mog_garden.onEventUpdate = function(player, csid, option, npc)
end

xi.mog_garden.onEventFinish = function(player, csid, option, npc)
end
