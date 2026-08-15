-----------------------------------
-- Get the Picture
-----------------------------------
-- Log ID: 6, Quest ID: 4
-- Balakaf : Aht Urhgan Whitegate (I-5)
-----------------------------------
-- !! NOT IMPLEMENTED -- DELIBERATELY INERT PENDING A LIVE CSID PROBE !!
--
-- This file intentionally registers nothing. `questAvailable` below is false, so
-- no section ever matches, so Balakaf is never claimed at
-- Action.Priority.Progress and this quest cannot hijack him or fire a stray
-- cutscene. Everything that has been established is recorded here so the next
-- person does not repeat the work.
--
-- WHY IT IS NOT BUILT: the csids cannot be decoded from our client dump, and
-- inventing one is not allowed.
--
-- What the stub did, and why it was wrong:
--   It fired csid 100 and completed the quest on one click. `xi-dat csid 50 100`
--   shows csid 100 is owned by the ZONE-GLOBAL ACTOR 0x7FFFFFF0 -- a 21-byte
--   program, `0x9F0880F8FFFF7FF8FFFF7F6D61696E06801C098000`, whose only string is
--   6D61696E = "main", a work variable, with no text opcode anywhere. It is a
--   system/state event, not a cutscene, and it does not belong to Balakaf. That
--   same zone-global actor owns csids 200 and 203, which are the two ferry warps
--   wired in Aht_Urhgan_Whitegate/Zone.lua -- i.e. exactly the family of ids
--   behind the An Imperial Heist ferry bug. Firing zone-global ids from an NPC is
--   the pattern to avoid.
--
-- WHAT THE DECODE ATTEMPT FOUND:
--   Balakaf is entity 16982337 (npc_list:4316); (16982337-16777216) = 205121,
--   205121//4096 = 50 rem 321 -> Aht Urhgan Whitegate, 0x01032141. He IS the
--   correct giver -- bg-wiki's Start field is "[[Balakaf]], [[Aht Urhgan
--   Whitegate]] (I-5)" for this quest and for Five Seconds of Fame.
--   csidmsg reports him owning 13 csids (515, 553-560, 586, 857, 873, 881), but
--   reading them back gives Magian-trial "Objective: ..." strings, the Ohohoroon
--   /Cacaroon lines 7273-7276, and tour-guide text 7382-7383. None of them is a
--   photography quest, so his real programs are not on his own entity -- the
--   Whitegate pattern, already seen in The Rider Cometh, is that quest programs
--   sit on separate proxy entities (that quest used 0x01032269 and 0x010321AD).
--   The proxy holding Balakaf's two quests has not been located.
--
--   Text-anchor search came back empty for every distinctive phrase on bg-wiki:
--     `xi-dat search 50 "photopticator"`     0 hits
--     `xi-dat search 50 "image recorder"`    0 hits  (both render as
--        ${item-singular} placeholders in dialog, so this was expected)
--     `xi-dat search 50 "volcano"`           1 hit, an unrelated Moblin line
--     `xi-dat search 50 "billowing"`         0 hits
--     `xi-dat search 50 "me own eyes"`       0 hits
--   -- the last two are quoted verbatim from bg-wiki's First Picture description
--   ("I'll never forget the plumes of smoke billowing from its peak, even though
--   it was a cloudy day when I saw it with me own eyes"), so this quest's dialog
--   is simply absent from our zone 50 table. CONTROL: the same table decodes
--   fine for other content -- msg 14503 is the Odin briefing and the 5000..5086
--   promotion series maps 1:1 onto the nine implemented Promotion_*.lua files --
--   so this is not a broken dump, it is missing text.
--
-- WHAT IS ALREADY PRESENT, so this is NOT blocked on data:
--   xi.ki.IMAGE_RECORDER = 773  (key_item.lua:772)
--   xi.ki.PHOTOPTICATOR  = 892  (key_item.lua:891)
--   Balakaf 16982337 in zone 50.
--
-- RETAIL FLOW, for whoever finishes it (bg-wiki "Get the Picture"):
--   Fame au, not repeatable. Next: Five Seconds of Fame.
--   Rewards: Imperial Silver Piece x8 and one Imperial Gold Piece.
--   Title: Scenic Snapshotter.
--   Item reqs: {KI} Image recorder, Light Cluster x3, Light Crystal x5, and an
--   Ahriman Lens each time you submit a wrong picture.
--   1. Speak to Balakaf to begin; he hands over the Image recorder.
--   2. Take eight requested pictures, one at a time, each matching a spoken
--      description. Some are gated on weather or time of day.
--   3. A correct picture pays an Imperial Silver Piece; you must then zone and
--      wait until JP midnight before the next one.
--   4. A wrong picture means zoning, speaking to him again, and trading an
--      Ahriman Lens to fix the camera.
--   Do not use an Aurora Crystal -- he rejects a photo with your name inscribed.
--
-- TO UNBLOCK: run a live `!cs` probe on Balakaf in Whitegate to capture the real
-- csid set, or locate his proxy entity in the zone 50 event dump. Once the offer
-- csid is known the eight-picture loop is ordinary work: a counter, a JP-midnight
-- gate (NextJstDay()), and a per-picture condition check.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.GET_THE_PICTURE)

-- Flip to true ONLY together with a real, decoded csid. Left false so the quest
-- registers no NPC binding at all.
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
