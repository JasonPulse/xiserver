-----------------------------------
-- Ported from Mishffera/lsb-server (https://github.com/Mishffera/lsb-server)
-- Source of Silver Sea Remnants + Lebros Assault content; adapted to this fork.
-----------------------------------
-----------------------------------
-- Area: Arrapago Remnants
--  NPC: Slot
-- Trade Bhaflau card to pop NM
-----------------------------------
local ID = zones[xi.zone.ARRAPAGO_REMNANTS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.SLOT_TRIGGER)
end

entity.onTrade = function(player, npc, trade)
    xi.salvage.handleSlot(player, npc, trade, xi.item.BHAFLAU_CARD, ID.mob[2][2].princess)
end

return entity
