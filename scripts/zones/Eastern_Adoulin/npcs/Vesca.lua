-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Vesca
-- Peacekeepers Coalition gear vendor
-- !pos -94 -0.650 17 257
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost          = 505
local REQUIRED_RANK = 1 -- Peacekeepers; raise for tighter gating

entity.onTrigger = function(player, npc)
    if xi.coalition.getRank(player, xi.coalition.PEACEKEEPERS) < REQUIRED_RANK then
        player:printToPlayer('You must be a Peacekeepers Coalition member of rank ' .. REQUIRED_RANK .. ' or higher.')
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
