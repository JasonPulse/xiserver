-----------------------------------
-- Area: Western Adoulin
--  NPC: Kithvalio
-- Sells Critical Chop key item for 20000 bayld (Inventors Coalition)
-- !pos -90 3.349 5 256
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

    if player:hasKeyItem(xi.ki.CRITICAL_CHOP) then
        player:startEvent(7573, 1, cost, 0, player:getCurrency('bayld'))
    else
        player:startEvent(7573, 0, cost, 0, player:getCurrency('bayld'))
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 7573 and option == 1 then
        if player:getCurrency('bayld') >= cost then
            player:delCurrency('bayld', cost)
            npcUtil.giveKeyItem(player, xi.ki.CRITICAL_CHOP)
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
