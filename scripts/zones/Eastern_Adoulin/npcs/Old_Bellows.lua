-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Old Bellows
-- Seed vendor
-- !pos 76 -0.150 -55 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.BAG_OF_VEGETABLE_SEEDS,    280 },
        { xi.item.BAG_OF_FRUIT_SEEDS,        320 },
        { xi.item.BAG_OF_GRAIN_SEEDS,        280 },
        { xi.item.BAG_OF_HERB_SEEDS,         280 },
        { xi.item.BAG_OF_CACTUS_STEMS,      1685 },
        { xi.item.BAG_OF_WILDGRASS_SEEDS,    320 },
    }

    xi.shop.general(player, stock, xi.fameArea.ADOULIN)
end

return entity
