-----------------------------------
-- A Discerning Eye (Windurst)
-----------------------------------
-- Log ID: 2, Quest ID: 89
-- Pygmalion : Port Windurst (M-7)
-----------------------------------
-- All four A Discerning Eye variants are the same quest on a different airship
-- route, so the whole implementation -- the decoded csids, the proof that option 0
-- accepts, the picture, the eight Passengers and the one-guess-only payout -- lives
-- in scripts/globals/discerning_eye.lua. Read that file's header for the full
-- decode and for what still needs an in-game probe.
--
-- This variant's specifics, each verified against sql/npc_list.sql:
--   giver     Pygmalion = 17760442 -> (17760442-16777216) = 983226, 983226//4096 = 240 rem 186
--   csid      10019, the ONLY event that entity owns
--   airship   zone 225, Passengers 17698820-17698827 owning csids 101-108 / 111-118
--
-- A previous pass had already decoded csid 10019 correctly, but left two faults
-- that are fixed here: it tested `option == 1` to accept when 12804 reads
-- "Return the dropped item? / Gladly. / Sorry, I'm a busy man/woman." -- so 1 is the
-- DECLINE -- and it auto-succeeded on merely zoning into the airship, skipping the
-- passenger identification entirely. Its `fame = 5` was invented too.
-----------------------------------
require('scripts/globals/discerning_eye')
-----------------------------------
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.A_DISCERNING_EYE)

quest.sections = xi.discerningEye.sections(quest,
{
    logId       = xi.questLog.WINDURST,
    questId     = xi.quest.id.windurst.A_DISCERNING_EYE,
    giverZone   = xi.zone.PORT_WINDURST,
    giverName   = 'Pygmalion',
    giverCsid   = 10019,
    airshipZone = xi.zone.WINDURST_JEUNO_AIRSHIP,
    clearsVar   = 'DiscerningEyeWindurstClears',
    passengers  =
    {
        17698820,
        17698821,
        17698822,
        17698823,
        17698824,
        17698825,
        17698826,
        17698827,
    },
})

return quest
