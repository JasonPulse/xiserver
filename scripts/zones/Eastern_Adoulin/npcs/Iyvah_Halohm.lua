-----------------------------------
-- Area: Eastern Adoulin (257)
--  NPC: Iyvah Halohm
-- Type: Adoulin Fame Checking NPC
-- !pos -61.044 -0.150 -5.239 257
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local imprimatursSpent = xi.coalition.getImprimatursSpent(player)
    local adoulinFame      = player:getFameLevel(xi.fameArea.ADOULIN)
    local ranks            = xi.coalition.getAllRanks(player)

    player:startEvent(562,
        imprimatursSpent, adoulinFame,
        ranks[xi.coalition.PIONEERS],
        ranks[xi.coalition.PEACEKEEPERS],
        ranks[xi.coalition.COURIERS],
        ranks[xi.coalition.SCOUTS],
        ranks[xi.coalition.INVENTORS],
        ranks[xi.coalition.MUMMERS])
end

return entity
