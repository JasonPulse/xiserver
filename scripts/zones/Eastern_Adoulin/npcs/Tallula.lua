-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Tallula
-- HELM tools and ammo vendor
-- !pos -22 -0.150 -53 257
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.PICKAXE,         200 },
        { xi.item.HATCHET,         500 },
        { xi.item.SICKLE,          300 },
        { xi.item.BULLET,          100 },
        { xi.item.CROSSBOW_BOLT,     6 },
    }

    xi.shop.general(player, stock, xi.fameArea.ADOULIN)
end

return entity
