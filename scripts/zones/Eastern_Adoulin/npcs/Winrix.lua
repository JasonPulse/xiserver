-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Winrix
-- Gobbie Mystery Box
-----------------------------------
---@type TNpcEntity
local entity = {}

local events =
{
    INTRO           = 5135,
    DEFAULT         = 5136,
    HOLDING_ITEM    = 5137,
    TRADE           = 5138,
    BAD_TRADE       = 5139,
    DAILY_COOLDOWN  = 5140,
    HIT_MAX         = 5141,
    RESULT          = 5144,
    KEY_TRADE       = 5145,
    NO_THANKS       = 5146,
    FULL_INV        = 5147,
    OTHER_BAD_TRADE = 5148,
}

entity.onTrade = function(player, npc, trade)
    xi.gobbieMysteryBox.onTrade(player, npc, trade, events)
end

entity.onTrigger = function(player, npc)
    xi.gobbieMysteryBox.onTrigger(player, npc, events)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.gobbieMysteryBox.onEventUpdate(player, csid, option, events)
end

entity.onEventFinish = function(player, csid, option, npc)
    xi.gobbieMysteryBox.onEventFinish(player, csid, option, events)
end

return entity
