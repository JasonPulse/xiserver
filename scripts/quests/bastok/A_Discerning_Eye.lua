-----------------------------------
-- A Discerning Eye (Bastok)
-----------------------------------
-- Log ID: 1, Quest ID: 71
-- Grin : Port Bastok (G-7)
-----------------------------------
-- All four A Discerning Eye variants are the same quest on a different airship
-- route, so the whole implementation -- the decoded csids, the proof that option 0
-- accepts, the picture, the eight Passengers and the one-guess-only payout -- lives
-- in scripts/globals/discerning_eye.lua. Read that file's header for the full
-- decode and for what still needs an in-game probe.
--
-- This variant's specifics, each verified against sql/npc_list.sql:
--   giver     Grin = 17744023 -> (17744023-16777216) = 966807, 966807//4096 = 236
--             rem 151, i.e. Port Bastok 0x010EC097 (npc_list:28326)
--   csid      295, the ONLY event that entity owns. `xi-dat csid 236 295` reports
--             two owners: the 752-byte program on Grin plus a 90-byte stub on
--             0x010EC098 = 17744024, which npc_list:28327 names 'csnpc' sitting at
--             Grin's exact coordinates (-56.533, 2.392, -29.432). That csnpc is the
--             mannequin the picture is displayed on.
--   airship   zone 224, Passengers 17694724-17694731 owning csids 101-108 / 111-118
--
-- Grin's program also reads the airship-schedule variables swsd/swbs/swws/swkz and
-- s232/s236/s240/s250 (the four ports), which is how retail decides whether a
-- departure is close enough to bother offering you the job.
--
-- CRITICAL BUG REMOVED: the previous stub used csids 140/141. csid 141 is the
-- AIRSHIP BOARDING FEE event -- scripts/zones/Port_Bastok/npcs/_6k8.lua:11
-- ('Door:Departures Exit', npc_list:28259), Rajesh.lua:11 and Varden.lua:17 all
-- fire it. Because onEventFinish is dispatched zone-wide keyed only on csid, the
-- stub's [141] handler ran when the player walked through the boarding door --
-- the quest's own next step -- silently completing the quest, paying 500 gil,
-- deleting the key item and incrementing the clear counter. The quest is
-- repeatable, so that was an unbounded gil faucet and free titles at 5/20/100.
-- csid 140 is real but belongs to 0x010EC056 = '_6k9' Door:Arrivals Entrance.
-- Neither is touched now.
--
-- The stub's `fame = 5` was invented: bg-wiki's Reward field is `*500 gil` only.
-- Its page does list `FLevel=1`, unlike the other three variants whose FLevel is
-- empty, so that one fame level is imposed here and only here.
-----------------------------------
require('scripts/globals/discerning_eye')
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.A_DISCERNING_EYE)

quest.sections = xi.discerningEye.sections(quest,
{
    logId       = xi.questLog.BASTOK,
    questId     = xi.quest.id.bastok.A_DISCERNING_EYE,
    giverZone   = xi.zone.PORT_BASTOK,
    giverName   = 'Grin',
    giverCsid   = 295,
    airshipZone = xi.zone.BASTOK_JEUNO_AIRSHIP,
    clearsVar   = 'DiscerningEyeBastokClears',
    fameLevel   = 1,
    fameArea    = xi.fameArea.BASTOK,
    passengers  =
    {
        17694724,
        17694725,
        17694726,
        17694727,
        17694728,
        17694729,
        17694730,
        17694731,
    },
})

return quest
