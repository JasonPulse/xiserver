-----------------------------------
-- Duties, Tasks, and Deeds
-----------------------------------
-- Log ID: 6, Quest ID: 71
-- Paparoon : Nashmau (G-7)
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Mythic chain #2, after An Imperial Heist (70) -- which is also inert.
--
-- WHY IT IS NOT BUILT:
-- csid 210 DOES NOT EXIST: `xi-dat csid 53 210` reports
--   "csid 210 not found in zone 53". It was hand-picked, not decoded, so the
--   NPC did nothing at all when triggered.
--   The gates themselves are also unbuildable at present: there is no Nyzul token
--   currency sink or all-50-Assault re-completion tracker in the repo.
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   `progressEvent(210)` then begin+complete on option 1, skipping the currency
--   and token gates entirely. 210 renders nothing, so it was unstartable.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   30,000 Alexandrite or Cat's Eye, 150,000 Nyzul tokens, AND re-completion of
--   all 50 Assaults.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.DUTIES_TASKS_AND_DEEDS)

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
