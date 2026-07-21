-----------------------------------
-- Area: Norg
--  NPC: Zurim
-----------------------------------
require('scripts/globals/domain_invasion')
-----------------------------------
---@type TNpcEntity
local entity = {}

local domainInvasionItems = xi.domainInvasion.rewardStock

entity.onTrade = function(player, npc, trade)
end

entity.onTrigger = function(player, npc)
    local domainInvPoints = player:getCurrency('domain_points')

    player:startEvent(9512, domainInvPoints)
end

entity.onEventUpdate = function(player, csid, option, npc)
    local itemPage = bit.band(bit.rshift(option, 2), 0x0F) + 1
    local itemSubPage = bit.band(bit.rshift(option, 10), 0x0F) + 1
    local itemSelected = bit.band(bit.rshift(option, 6), 0x0F) + 1
    local domainInvPurchase = domainInvasionItems[itemPage][itemSubPage][itemSelected]
    local domainInvPoints = player:getCurrency('domain_points')

    if npcUtil.giveItem(player, { { domainInvPurchase.item, 1 } }) then
        player:delCurrency('domain_points', domainInvPurchase.cost)
    end

    player:updateEvent(domainInvPoints - domainInvPurchase.cost)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
