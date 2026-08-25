-----------------------------------
-- Area: Port Windurst (240)
--  NPC: Skipper Moogle
-- Type: Mog Garden rank book vendor (gil)
-- !pos -194.05 -2 67.008 240
-----------------------------------
-- Retail (bg-wiki and FFXIclopedia "Skipper Moogle"). Explains Mog Gardens and who is
-- let into one, and sells the books that raise the rank of a geological location, at
-- 10000 / 20000 / 40000 / 80000 / 160000 / 320000 gil for ranks 2 through 7. Zenicca
-- in Western Adoulin sells the same books cheaper for bayld.
--
-- csid 897 is decoded from our own client DAT dump: it is the only event on entity
-- 17760509, and its data table is identical to the other two ports' Skipper Moogles,
-- carrying the six gil prices, the per-family purchase thresholds and the thirty rank
-- books. Port San d'Oria's 809 was additionally confirmed live at the puppet, which
-- validates the shape for all three. The program branches on the first zone work var
-- three ways for nation-specific directions, which is what the nation index selects.
--
-- The menu tree is in scripts/globals/mog_garden/vendor.lua, read off the Selection
-- Dialog text rather than off the bytecode: a control-flow trace of this program
-- desyncs on the variable-length opcodes, so its data[] reads cannot be trusted to
-- name the messages that actually run.
--
-- See that file also for the two parts of the purchase a live click still has to
-- settle.
-----------------------------------
---@type TNpcEntity
local entity = {}

local bookShopEvent = 897

entity.onTrigger = function(player, npc)
    xi.mog_garden.vendor.onTrigger(player)

    return player:startEvent(bookShopEvent, xi.mog_garden.vendor.nation[xi.zone.PORT_WINDURST],
        xi.mog_garden.vendor.eventParams(player, 'gil'))
end

entity.onEventUpdate = function(player, csid, option, npc)
    if csid == bookShopEvent then
        xi.mog_garden.vendor.onEventUpdate(player, option, 'gil', true)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == bookShopEvent then
        xi.mog_garden.vendor.onEventFinish(player, option, 'gil', true)
    end
end

return entity
