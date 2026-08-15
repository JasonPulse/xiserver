-----------------------------------
-- A Discerning Eye (San d'Oria)
-----------------------------------
-- Log ID: 0, Quest ID: 104
-- Eddy : Port San d'Oria (H-6)
-----------------------------------
-- All four A Discerning Eye variants are the same quest on a different airship
-- route, so the whole implementation -- the decoded csids, the proof that option 0
-- accepts, the picture, the eight Passengers and the one-guess-only payout -- lives
-- in scripts/globals/discerning_eye.lua. Read that file's header for the full
-- decode and for what still needs an in-game probe.
--
-- This variant's specifics, each verified against sql/npc_list.sql:
--   giver     Eddy = 17727617 -> (17727617-16777216) = 950401, 950401//4096 = 232 rem 129
--   csid      723, the ONLY event that entity owns
--   airship   zone 223, Passengers 17690629-17690636 owning csids 101-108 / 111-118
--
-- The stub fired csid 585, which Eddy does not own. bg-wiki's FLevel field is
-- empty for this variant, so no fame requirement is imposed, and its Reward field is
-- `*500 gil` only -- the stub's `fame = 5` was invented.
--
-- The stub also used charvar 'DiscerningEyeClears', unprefixed, which would have
-- shared its clear count with any other variant that picked the same name. Each
-- variant now has its own.
-----------------------------------
require('scripts/globals/discerning_eye')
-----------------------------------
local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.A_DISCERNING_EYE)

quest.sections = xi.discerningEye.sections(quest,
{
    logId       = xi.questLog.SANDORIA,
    questId     = xi.quest.id.sandoria.A_DISCERNING_EYE,
    giverZone   = xi.zone.PORT_SAN_DORIA,
    giverName   = 'Eddy',
    giverCsid   = 723,
    airshipZone = xi.zone.SAN_DORIA_JEUNO_AIRSHIP,
    clearsVar   = 'DiscerningEyeSandoriaClears',
    passengers  =
    {
        17690629,
        17690630,
        17690631,
        17690632,
        17690633,
        17690634,
        17690635,
        17690636,
    },
})

return quest
