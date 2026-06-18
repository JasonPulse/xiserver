-----------------------------------
-- Area: Reisenjima (291)
-- NPC: ???
-- Notes: Grants "Ethereal droplet" temporary item. Also doubles as a Geas
--        Fete / Wildskeeper Reive pop trigger: if the player holds (or has
--        pinned via Pop_Selection CharVar) a pop KI mapped to Reisenjima,
--        the corresponding boss spawns and the KI is consumed before the
--        droplet grant.
-----------------------------------
require('scripts/globals/pop_trigger')
-----------------------------------
local ID = zones[xi.zone.REISENJIMA]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if xi.popTrigger.tryPop(player) then
        return
    end

    if player:hasItem(xi.item.ETHEREAL_DROPLET, xi.inv.TEMPITEMS) then
        player:messageSpecial(ID.text.NOTHING_OUT_OF_ORDINARY)
    else
        player:addTempItem(xi.item.ETHEREAL_DROPLET, 1)
        player:messageSpecial(ID.text.ITEM_OBTAINED, xi.item.ETHEREAL_DROPLET)
    end
end

return entity
