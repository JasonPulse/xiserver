-----------------------------------
-- Area: Eastern Adoulin (257)
--  NPC: Iyvah Halohm
-- Type: Adoulin Fame Checking NPC
-- !pos -61.044 -0.150 -5.239 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local imprimatursSpent = player:getCharVar('Coalition_Imprimaturs_Spent')
    local adoulinFame = player:getFameLevel(xi.fameArea.ADOULIN)
    local pioneersRank = player:getCharVar('Coalition_Pioneers_Rank')
    local peacekeepersRank = player:getCharVar('Coalition_Peacekeepers_Rank')
    local couriersRank = player:getCharVar('Coalition_Couriers_Rank')
    local scoutsRank = player:getCharVar('Coalition_Scouts_Rank')
    local inventorsRank = player:getCharVar('Coalition_Inventors_Rank')
    local mummersRank = player:getCharVar('Coalition_Mummers_Rank')

    player:startEvent(562,
        imprimatursSpent, adoulinFame,
        pioneersRank, peacekeepersRank, couriersRank,
        scoutsRank, inventorsRank, mummersRank)
end

return entity
