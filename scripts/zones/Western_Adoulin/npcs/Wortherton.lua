-----------------------------------
-- Area: Western Adoulin
--  NPC: Wortherton
-- Inventors Coalition crafting ring vendor
-- !pos 91 -0.651 -78 256
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
local ID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost          = 20000
local REQUIRED_RANK = 1 -- Inventors; raise for tighter gating

entity.onTrigger = function(player, npc)
    if xi.coalition.getRank(player, xi.coalition.INVENTORS) < REQUIRED_RANK then
        player:printToPlayer('You must be an Inventors Coalition member of rank ' .. REQUIRED_RANK .. ' or higher.')
        return
    end

    player:startEvent(7593, 0, cost, 0, player:getCurrency('bayld'))
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7593 and option == 1 then
        if player:getCurrency('bayld') >= cost then
            if npcUtil.giveItem(player, xi.item.CRAFTKEEPERS_RING) then
                player:delCurrency('bayld', cost)
            end
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
