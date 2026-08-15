-----------------------------------
-- A Stygian Pact
-----------------------------------
-- Log ID: 6, Quest ID: 78
-- Nashmeira : Aht Urhgan Whitegate
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Odin arc #3, after Unwavering Resolve (77) -- which is also inert.
--
-- WHY IT IS NOT BUILT:
-- csid 320 DOES NOT EXIST: `xi-dat csid 50 320` reports
--   "csid 320 not found in zone 50". It was hand-picked, not decoded, so the
--   NPC did nothing at all when triggered.
--   Same Nashmeira problem as Unwavering Resolve: every zone-50 Nashmeira row is
--   status 6, so she is not a clickable NPC there.
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   `progressEvent(320)` then begin+complete on option 1. 320 renders nothing.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   Gates on Unwavering Resolve. {KI} Stygian pact phantom gem (3185) already
--   exists in scripts/enum/key_item.lua, so the reward side is partly present.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.A_STYGIAN_PACT)

-- Flip to true ONLY together with real, decoded csids and the content below.
local questAvailable = false

quest.sections =
{
    {
        check = function(player, status, vars)
            return questAvailable
        end,
    },
}

return quest
