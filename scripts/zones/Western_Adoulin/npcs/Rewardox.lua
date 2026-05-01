-----------------------------------
-- Area: Western Adoulin
--  NPC: Rewardox
-- Gobbie Mystery Box
-----------------------------------
---@type TNpcEntity
local entity = {}

local events =
{
    INTRO           = 5129,
    DEFAULT         = 5130,
    HOLDING_ITEM    = 5131,
    TRADE           = 5132,
    BAD_TRADE       = 5133,
    DAILY_COOLDOWN  = 5134,
    HIT_MAX         = 5135,
    RESULT          = 5138,
    KEY_TRADE       = 5139,
    NO_THANKS       = 5140,
    FULL_INV        = 5141,
    OTHER_BAD_TRADE = 5142,
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
