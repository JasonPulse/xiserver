-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Craggy Bluff
-- Peacekeepers Coalition weapon vendor
-- !pos -95 -0.649 22 257
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local cost = 500

entity.onTrigger = function(player, npc)
    player:startEvent(7575, 0, cost, 0, player:getCurrency('bayld'))
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7575 and option == 1 then
        if player:getCurrency('bayld') >= cost then
            if npcUtil.giveItem(player, xi.item.VINESLASH_CESTI) then
                player:delCurrency('bayld', cost)
            end
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
