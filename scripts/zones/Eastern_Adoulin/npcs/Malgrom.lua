-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Malgrom
-- Seafood vendor
-- !pos -67 -0.150 -25 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.SENROH_SKEWER,    6832 },
        { xi.item.NEBIMONITE_BAKE,  1800 },
        { xi.item.ROAST_TROUT,       600 },
        { xi.item.ROAST_CARP,        520 },
    }

    xi.shop.general(player, stock, xi.fameArea.ADOULIN)
end

return entity
