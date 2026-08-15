-----------------------------------
-- A Discerning Eye (Kazham)
-----------------------------------
-- Log ID: 5, Quest ID: 14
-- Swift : Kazham (H-7)
-----------------------------------
-- All four A Discerning Eye variants are the same quest on a different airship
-- route, so the whole implementation -- the decoded csids, the proof that option 0
-- accepts, the picture, the eight Passengers and the one-guess-only payout -- lives
-- in scripts/globals/discerning_eye.lua. Read that file's header for the full
-- decode and for what still needs an in-game probe.
--
-- This variant's specifics, each verified against sql/npc_list.sql:
--   giver     Swift = 17801340 -> (17801340-16777216) = 1024124, 1024124//4096 = 250 rem 124
--   csid      10018, the ONLY event that entity owns
--   airship   zone 226, Passengers 17702916-17702923 owning csids 101-108 / 111-118
--
-- CRITICAL BUG REMOVED: the stub handled csids 200 and 201, which in Kazham belong
-- to The Opo-opo and I -- 200 is fired by scripts/zones/Kazham/npcs/Roropp.lua and
-- 201 by scripts/zones/Kazham/npcs/Popopp.lua. Because onEventFinish dispatches
-- zone-wide keyed only on csid, running that quest drove this one: Roropp granted
-- the Dropped item and Popopp completed the quest, paying 500 gil and counting a
-- title clear. This quest is repeatable, so it was an unbounded gil and title
-- faucet driven entirely by an unrelated quest. Swift's real csid is 10018.
--
-- bg-wiki gives `|Fame=k` and an empty FLevel for this variant; Kazham fame is
-- xi.fameArea.WINDURST (fame_area.lua:10 comments it "Mhaura, Kazham"). No fame is
-- granted, because the Reward field is `*500 gil` only.
-----------------------------------
require('scripts/globals/discerning_eye')
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.A_DISCERNING_EYE)

quest.sections = xi.discerningEye.sections(quest,
{
    logId       = xi.questLog.OUTLANDS,
    questId     = xi.quest.id.outlands.A_DISCERNING_EYE,
    giverZone   = xi.zone.KAZHAM,
    giverName   = 'Swift',
    giverCsid   = 10018,
    airshipZone = xi.zone.KAZHAM_JEUNO_AIRSHIP,
    clearsVar   = 'DiscerningEyeKazhamClears',
    passengers  =
    {
        17702916,
        17702917,
        17702918,
        17702919,
        17702920,
        17702921,
        17702922,
        17702923,
    },
})

return quest
