-----------------------------------
-- Area: Western Adoulin
--  NPC: Zenicca
-- Type: Mog Garden rank book vendor (bayld)
-- !pos -90.272 3.849 -47.666 256
-----------------------------------
-- Retail (bg-wiki and FFXIclopedia "Zenicca"). Exchanges bayld for the books that
-- raise the rank of a Mog Garden geological location, at 1000 / 3000 / 5000 / 7000 /
-- 9000 / 11000 for ranks 2 through 7. The same books cost gil from a Skipper Moogle in
-- one of the three ports, dearer. She is only on her pitch once the Pioneers'
-- Coalition has reached edification rank 4, and unlike the Skipper Moogles she offers
-- no explanation of what each book does, because she runs the shared Adoulin
-- bayld-vendor menu tree rather than a bespoke one: greeting 12040, list 12027 (row
-- prices in params 17 and up), detail 12031, confirm 12032.
--
-- csid 7502 is decoded from our own client DAT dump: it is the only substantial event
-- on entity 17826131, and its event data table carries the six bayld prices above
-- alongside key items 2412 to 2446. See scripts/globals/mog_garden/vendor.lua for the
-- full decode, the menu trees, and the two things a live purchase still has to settle.
-----------------------------------
---@type TNpcEntity
local entity = {}

local bookShopEvent = 7502

entity.onTrigger = function(player, npc)
    if xi.coalition.getRank(player, xi.coalition.PIONEERS) < xi.mog_garden.vendor.ZENICCA_EDIFICATION_RANK then
        return
    end

    xi.mog_garden.vendor.onTrigger(player)

    return player:startEvent(bookShopEvent, xi.mog_garden.vendor.eventParams(player, 'bayld'))
end

entity.onEventUpdate = function(player, csid, option, npc)
    if csid == bookShopEvent then
        xi.mog_garden.vendor.onEventUpdate(player, option, 'bayld', false)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == bookShopEvent then
        xi.mog_garden.vendor.onEventFinish(player, option, 'bayld', false)
    end
end

return entity
