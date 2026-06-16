-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Vesca
-- Peacekeepers Coalition gear vendor (full Karieyh i119 set).
--
-- Retail Vesca sells the full Karieyh armor set (5 pieces) to
-- Peacekeepers rank-1 members for bayld. CSID 7574 covers a single-
-- piece purchase event flow (Morion only); the multi-piece selection
-- uses the server-standard `<NPC>_Selection` CharVar pin pattern:
--
--   !setvar Vesca_Selection N    (1=Morion, 2=Haubert, 3=Moufles,
--                                 4=Brayettes, 5=Sollerets)
--   trigger Vesca
--
-- With no pin set, the existing CSID 7574 flow runs unchanged (Morion).
-- !pos -94 -0.650 17 257
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost          = 505
local requiredRank = 1 -- Peacekeepers; raise for tighter gating

local vescaPinVar = 'Vesca_Selection'
local karieyh =
{
    [1] = { name = 'Karieyh Morion',     itemId = 27785 }, -- head
    [2] = { name = 'Karieyh Haubert',    itemId = 27925 }, -- body
    [3] = { name = 'Karieyh Moufles',    itemId = 28065 }, -- hands
    [4] = { name = 'Karieyh Brayettes',  itemId = 28205 }, -- legs
    [5] = { name = 'Karieyh Sollerets',  itemId = 28345 }, -- feet
}

local function tryPinnedPurchase(player)
    local pinned = player:getCharVar(vescaPinVar)
    if pinned == 0 then
        return false
    end

    local entry = karieyh[pinned]
    if not entry then
        player:printToPlayer(string.format('Vesca_Selection %d is not valid (1-5). See Vesca.lua.', pinned))
        player:setCharVar(vescaPinVar, 0)
        return true
    end

    if player:getCurrency('bayld') < cost then
        player:printToPlayer(string.format('%s costs %d bayld. You have %d.', entry.name, cost, player:getCurrency('bayld')))
        player:setCharVar(vescaPinVar, 0)
        return true
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    if not npcUtil.giveItem(player, entry.itemId) then
        player:printToPlayer(string.format('Inventory full — %s not granted.', entry.name))
        return true
    end

    player:delCurrency('bayld', cost)
    player:setCharVar(vescaPinVar, 0)
    player:printToPlayer(string.format('%s purchased (-%d bayld).', entry.name, cost))
    return true
end

entity.onTrigger = function(player, npc)
    if xi.coalition.getRank(player, xi.coalition.PEACEKEEPERS) < requiredRank then
        player:printToPlayer('You must be a Peacekeepers Coalition member of rank ' .. requiredRank .. ' or higher.')
        return
    end

    if tryPinnedPurchase(player) then
        return
    end

    player:startEvent(7574, 0, cost, 0, player:getCurrency('bayld'))
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7574 and option == 1 then
        if player:getCurrency('bayld') >= cost then
            if npcUtil.giveItem(player, xi.item.KARIEYH_MORION) then
                player:delCurrency('bayld', cost)
            end
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
