-----------------------------------
-- Area: Gusgen Mines
--  NPC: qm3 (???)
-- Involved In Quest: Healing the Land
-- !pos -168 1 311 196
-----------------------------------
local ID = zones[xi.zone.GUSGEN_MINES]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.LETTERS_IS_WRITTEN_HERE)
end

return entity
