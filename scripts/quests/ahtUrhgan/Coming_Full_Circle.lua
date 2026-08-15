-----------------------------------
-- Coming Full Circle
-----------------------------------
-- Log ID: 6, Quest ID: 73
-- Paparoon : Nashmau (G-7) / Caedarva Mire tombstone
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Mythic chain #4, the final one, after Forging a New Myth (72) -- also inert.
--
-- WHY IT IS NOT BUILT:
-- csid 230 DOES NOT EXIST: `xi-dat csid 53 230` reports
--   "csid 230 not found in zone 53". It was hand-picked, not decoded, so the
--   NPC did nothing at all when triggered.
--   And the reward itself does not exist: there is no Mythic weapon pipeline, so
--   there is nothing to hand over even if the flow were wired.
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   `progressEvent(230)` then begin+complete on option 1, with the header openly
--   admitting "Mythic weapon grant is abstracted". 230 renders nothing.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   Trade the statless Mythic weapon plus a relief shard at the Caedarva Mire
--   tombstone to receive the finished level 75 Mythic Weapon.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.COMING_FULL_CIRCLE)

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
