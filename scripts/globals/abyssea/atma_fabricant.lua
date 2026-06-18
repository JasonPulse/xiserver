-----------------------------------
-- Abyssea Atma Fabricant
--
-- Retail: trade an Atma Stone (NM-specific drop) to receive the corresponding
-- Atma key item. Atma stones don't exist in our item DB (upstream gap) and no
-- NM script currently grants atma KIs, so without this NPC players cannot
-- obtain atmas at all outside GM commands.
--
-- Our stub: simplified cruor + visitant-lights purchase keyed to a single
-- CharVar `Atma_Selection` (set to the atma KI id, 1279..1423). One trigger
-- per visit attempts to grant the pinned atma; if the player already has it,
-- another can be pinned. Unpinned = nothing happens.
--
-- Cost model (configurable via the locals below):
--   - 2000 cruor
--   - 1 of each visitant light (Pearl/Ebon/Golden/Silvery/Azure/Ruby/Amber)
--
-- GM usage: `!setvar Atma_Selection 1279` (or via the future selector NPC).
-----------------------------------
require('scripts/globals/abyssea')
require('scripts/globals/abyssea/atma')
-----------------------------------
xi = xi or {}
xi.atmaFabricant = xi.atmaFabricant or {}

local atmaSelectionVar = 'Atma_Selection'
local cruorCost        = 2000
local lightCost        = 1 -- per colour

-- Membership in xi.atma.atmaMods is the source of truth for "is this KI an
-- atma?" — covers the actual KIs the equip/effect system recognises and
-- skips any stale CharVar pin that points outside the table.
local function isValidAtmaKey(keyItemId)
    return xi.atma.atmaMods[keyItemId] ~= nil
end

local function spendLights(player, lightTable, perColour)
    for _, lightId in pairs(xi.abyssea.lightType) do
        lightTable[lightId] = lightTable[lightId] - perColour
    end
end

local function hasEnoughLights(lightTable, perColour)
    for _, lightId in pairs(xi.abyssea.lightType) do
        if lightTable[lightId] < perColour then
            return false
        end
    end

    return true
end

-- Persist the modified light table back into the two packed CharVars used by
-- the rest of the abyssea light code.
local function writeLightsTable(player, lightTable)
    local lightMaskFirst  = 0
    local lightMaskSecond = 0

    for k = 1, 7 do
        if k <= 4 then
            lightMaskFirst = lightMaskFirst + bit.lshift(lightTable[k], (k - 1) * 8)
        else
            lightMaskSecond = lightMaskSecond + bit.lshift(lightTable[k], (k - 1) * 8)
        end
    end

    player:setCharVar('abysseaLights1', lightMaskFirst)
    player:setCharVar('abysseaLights2', lightMaskSecond)
end

xi.atmaFabricant.onTrade = function(player, npc, trade)
end

xi.atmaFabricant.onTrigger = function(player, npc)
    local ID = zones[player:getZoneID()]

    if not player:hasStatusEffect(xi.effect.VISITANT) then
        player:messageSpecial(ID.text.NO_VISITANT_STATUS)
        return
    end

    local pinned = player:getCharVar(atmaSelectionVar)
    if not isValidAtmaKey(pinned) then
        player:printToPlayer('The Atma Fabricant awaits your selection. Pin an atma via `!setvar Atma_Selection <atma KI id>` (see scripts/enum/key_item.lua ATMA_OF_* entries) and try again.')
        return
    end

    if player:hasKeyItem(pinned) then
        player:printToPlayer('You already possess that atma. Pin a different one.')
        return
    end

    if player:getCurrency('cruor') < cruorCost then
        player:printToPlayer(string.format('You need %d cruor to forge this atma.', cruorCost))
        return
    end

    local lightTable = xi.abyssea.getLightsTable(player)
    if not hasEnoughLights(lightTable, lightCost) then
        player:printToPlayer(string.format('You need %d of each visitant light to forge an atma.', lightCost))
        return
    end

    player:delCurrency('cruor', cruorCost)
    spendLights(player, lightTable, lightCost)
    writeLightsTable(player, lightTable)
    npcUtil.giveKeyItem(player, pinned)
    player:messageSpecial(ID.text.ATMA_INFUSED, cruorCost, pinned)
end

xi.atmaFabricant.onEventUpdate = function(player, csid, option, npc)
end

xi.atmaFabricant.onEventFinish = function(player, csid, option, npc)
end
