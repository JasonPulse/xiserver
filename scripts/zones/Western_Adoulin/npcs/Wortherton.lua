-----------------------------------
-- Area: Western Adoulin
--  NPC: Wortherton
-- Inventors Coalition crafting ring vendor
-- !pos 91 -0.651 -78 256
-----------------------------------
local ID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost = 20000

entity.onTrigger = function(player, npc)
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
