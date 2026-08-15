-----------------------------------
-- Forging a New Myth
-----------------------------------
-- Log ID: 6, Quest ID: 72
-- Nashmeira : Aht Urhgan Whitegate
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches and no NPC is claimed at Action.Priority.Progress.
-- Full requirements for the whole arc are in ODIN_MYTHIC_ARC_TODO.md at repo root.
--
-- Mythic chain #3, after Duties, Tasks, and Deeds (71) -- which is also inert.
--
-- WHY IT IS NOT BUILT:
--   The boss fights do not exist: retail needs Zahak and Balrahn, and neither is
--   built. Nor is the Mythic weapon pipeline that Coming Full Circle needs.
--
-- WHAT THE STUB DID, AND WHY IT HAD TO GO:
--   CRITICAL BUG REMOVED -- this one was a live cross-fire, not merely a dead id.
--   The stub handled `onEventFinish[220]` in AHT_URHGAN_WHITEGATE. csid 220 in
--   zone 50 has three owners, and the real 95-byte program belongs to ZARFHID
--   (16982033) -- its bytecode references the work vars 746C6B32 = "tlk2" and
--   idl0 -- with 1-byte stubs on _1ec 'Door_1ea' (16982062) and 16982036.
--   scripts/zones/Aht_Urhgan_Whitegate/npcs/Zarfhid.lua:9 fires it
--   unconditionally on trigger and handles option 333 to delete a Ferry ticket.
--   Because onEventFinish dispatches zone-wide keyed only on csid, simply
--   TALKING TO ZARFHID would begin and instantly complete Mythic chain quest #3
--   for any player who had finished Duties, Tasks, and Deeds. The stub also
--   fired `progressEvent(220)` from Nashmeira, i.e. it opened Zarfhid's own
--   talk event from a different NPC.
--
-- RETAIL REQUIREMENTS (bg-wiki), for whoever builds it:
--   Collect Tinnin's Fang, Sarameya's Hide and Tyger's Tail, then defeat Zahak
--   and Balrahn.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FORGING_A_NEW_MYTH)

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
