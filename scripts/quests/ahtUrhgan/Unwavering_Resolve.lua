-----------------------------------
-- Unwavering Resolve
-----------------------------------
-- Log ID: 6, Quest ID: 77
-- Nashmeira : Aht Urhgan Whitegate
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Odin arc #2, after The Rider Cometh (76).
-- NOTE: The Rider Cometh HAS now been rebuilt, and the Odin Prime battlefield with
-- it, so this quest is genuinely reachable again -- which is exactly why leaving a
-- fabricated-csid stub here was no longer safe.
--
-- WHY IT IS NOT BUILT:
-- csid 310 DOES NOT EXIST: `xi-dat csid 50 310` reports
--   "csid 310 not found in zone 50". It was hand-picked, not decoded, so the
--   NPC did nothing at all when triggered.
--   Nashmeira's real programs are not on her own entity either: all three zone-50
--   'Nashmeira' rows (16982184, 16982219, 16982220) carry status 6, i.e.
--   cutscene-only and not clickable. Whitegate quest programs sit on proxy
--   entities, as The Rider Cometh's did (0x01032269 and 0x010321AD).
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   `progressEvent(310)` then begin+complete on option 1. Since 310 renders
--   nothing, the quest was unstartable rather than exploitable -- but it still
--   claimed Nashmeira at priority 1000 for any eligible player.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   Gates on The Rider Cometh. Rebuild it together with A Stygian Pact once the
--   Whitegate proxy csids are probed live; see ODIN_MYTHIC_ARC_TODO.md.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.UNWAVERING_RESOLVE)

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
