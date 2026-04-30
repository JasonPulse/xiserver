-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Quiri-Aliri
-- Casts Ionis on players for 10 bayld.
-- !pos -53 -0.150 85 257
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local ionisCost = 10
local ionisDuration = 9000

entity.onTrigger = function(player, npc)
    player:startEvent(1200, 1, 0, 30, 34, 2157, ionisCost)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 1200 and option == 1 then
        if player:getCurrency('bayld') >= ionisCost then
            player:delCurrency('bayld', ionisCost)
            player:delStatusEffectsByFlag(xi.effectFlag.INFLUENCE, true)
            player:addStatusEffect(xi.effect.IONIS, 0, 0, ionisDuration)
        else
            player:messageSpecial(ID.text.NOT_ENOUGH_BAYLD)
        end
    end
end

return entity
