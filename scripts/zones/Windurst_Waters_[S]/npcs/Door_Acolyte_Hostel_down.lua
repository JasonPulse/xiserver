-----------------------------------
-- Area: Windurst Waters (S)
--  NPC: Door Acolyte Hostel
-- !pos  124.000, -3.000, 222.215 94
-----------------------------------
-- DOUBLE-REWARD REMOVED. This file used to re-implement The Tigress Stirs and
-- Knot Quite There alongside the Interaction Framework versions of both. Its
-- onEventFinish granted a Hi-Elixir and completed The Tigress Stirs on csid 129,
-- while WOTG_WIN_1_The_Tigress_Stirs.lua does the same on the same csid -- and
-- interaction_lookup.lua runs BOTH the framework handler and the legacy fallback
-- for onEventFinish (only onSteal/onTrigger/onTrade are excluded), so the player
-- received two Hi-Elixirs. csid 151/152 are likewise owned by
-- WOTG_WIN_3_Knot_Quite_There.lua.
--
-- All the quest branches are therefore deleted. What is kept is the one thing the
-- framework does not provide: the locked-door message for anyone who is not on
-- these quests. Unlike the other legacy files retired with it, this door has no
-- DefaultActions entry to fall back on.
-----------------------------------
local ID = zones[xi.zone.WINDURST_WATERS_S]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    player:messageSpecial(ID.text.DOOR_ACOLYTE_HOSTEL_LOCKED)
end

return entity
