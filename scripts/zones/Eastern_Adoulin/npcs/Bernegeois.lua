-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Bernegeois
-- Cafe food and drink vendor
-- !pos -36 -0.150 -7 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.BOTTLE_OF_FRONTIER_SODA,    125 },
        { xi.item.BOWL_OF_ULBUCONUT_MILK,     560 },
        { xi.item.BAR_OF_CAMPFIRE_CHOCOLATE,   20 },
        { xi.item.TRAIL_COOKIE,                 8 },
        { xi.item.PIECE_OF_CASCADE_CANDY,      20 },
        { xi.item.SLICE_OF_GRILLED_HARE,      184 },
        { xi.item.BOWL_OF_MUSHROOM_SOUP,     7000 },
        { xi.item.CUP_OF_CHOCOMILK,          4560 },
        { xi.item.POT_OF_SAN_DORIAN_TEA,     2772 },
    }

    xi.shop.general(player, stock, xi.fameArea.ADOULIN)
end

return entity
