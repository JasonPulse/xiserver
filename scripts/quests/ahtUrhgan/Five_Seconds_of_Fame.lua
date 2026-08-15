-----------------------------------
-- Five Seconds of Fame
-----------------------------------
-- Log ID: 6, Quest ID: 32
-- Balakaf : Aht Urhgan Whitegate (I-5)
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT PENDING A LIVE CSID PROBE !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches, so Balakaf is never claimed at
-- Action.Priority.Progress. See scripts/quests/ahtUrhgan/Get_the_Picture.lua for
-- the shared decode notes -- that quest is this one's prerequisite and the same
-- undecodable-csid blocker applies to both.
--
-- CRITICAL BUG REMOVED -- this is why the file could not simply be left as it was.
-- The stub fired csid 150 and handled `onEventFinish[150]` in
-- AHT_URHGAN_WHITEGATE, completing the quest on one click. csid 150 in Whitegate
-- is the IMPERIAL COIN EXCHANGE, fired by
-- scripts/zones/Aht_Urhgan_Whitegate/npcs/Ugrihd.lua:44 as
-- `player:startEvent(150, rank, badge, points, ...)`. Because onEventFinish
-- dispatches zone-wide keyed only on csid, exchanging imperial standing for
-- Imperial Bronze/Silver/Mythril/Gold Pieces at Ugrihd could complete this quest
-- -- and this quest's reward IS imperial pieces, so it was paying out of the same
-- currency the player was already spending at.
--
-- Note also that `xi-dat csid 50 150` reports "csid 150 not found in zone 50":
-- there is no bytecode program for it, because the coin exchange is a client-side
-- menu driven purely by the params Ugrihd passes. So the stub's
-- `progressEvent(150)` was not showing a quest cutscene at all -- it was opening
-- the coin-exchange window from Balakaf.
--
-- WHAT IS ALREADY PRESENT, so this is NOT blocked on data:
--   xi.ki.PHOTOPTICATOR = 892 (key_item.lua:891)
--   Balakaf 16982337 (zone 50 idx 321, 0x01032141)
--   Six of the scene NPCs bg-wiki names all exist in zone 50:
--     Zyfhil  16982124   Talwahn 16982127   Ulamaal 16982274
--     Qutiba  16982273   Ratihb  16982264   Zubyahn 16982146
--   (Qutiba, Ratihb and Zubyahn have additional rows; Ratihb and Zubyahn also
--   appear in zone 51. Pick the zone 50 instances.)
--
-- RETAIL FLOW, for whoever finishes it (bg-wiki "Five Seconds of Fame"):
--   Fame none, not repeatable. Previous: Get the Picture.
--   Rewards: Imperial Bronze Piece x3, Imperial Silver Piece x2, and one
--   Imperial Mythril Piece. Title: Photopticator Operator.
--   1. Talk to Balakaf (I-5) to receive the Photopticator.
--   2. Record one case per Vana'diel day, in any order. After a successful
--      recording, talk to Balakaf before the next is possible. On a failure you
--      must zone before retrying.
--   3. The cases are timed city scenes, e.g.
--      * A Pickpocket's Paradise (from 15:00) -- talk to Zyfhil (F-8), then
--        Talwahn (F-8) after 15:00; begin recording once the thief (Hume Male,
--        Face 8, Hair B) stands behind the visitor, and you succeed by recording
--        the pickpocketing. Afterwards talk to Balakaf, then Zyfhil.
--      * Special of the Day (from 5:00) -- talk to Ulamaal (K-12), then Qutiba
--        for a clue, then Ratihb (J-12) after 5:00 and pick the option matching
--        the clue; talk to Zubyahn (K-12) and start recording shortly after the
--        pumpkin head reaches the front of the queue, succeeding by recording it
--        leaving the counter and rejoining the back of the line. Then Balakaf,
--        then Ulamaal.
--      * Smells Like a Rat (from 14:00) -- and further cases.
--
-- TO UNBLOCK: the csid probe described in Get_the_Picture.lua. Beyond the csids
-- this one also needs real scene choreography -- timed NPC pathing and a
-- recording window judged against a specific moment -- so it is materially more
-- work than the eight-picture quest, and neither should be flipped on until the
-- ids are real.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FIVE_SECONDS_OF_FAME)

-- Flip to true ONLY together with a real, decoded csid. Left false so the quest
-- registers no NPC binding at all, and in particular so nothing in this file ever
-- handles csid 150 again.
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
