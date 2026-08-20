-----------------------------------
-- VW Op. 026: Tavnazian Terrors
-----------------------------------
-- Log ID: 4, Quest ID: 84
-- Owain : Tavnazian Safehold (H-6), entity 16883890
-- !addquest 4 84
-----------------------------------
-- Retail (bg-wiki "VW Op. 026: Tavnazian Terrors").
-- |Start=Owain, Tavnazian Safehold  |Fame=Other  |Reward=Hyacinth stratum abyssite
-- |Quest Reqs=Adventurer Certificate, Level 75 or higher
--   1. Speak with Owain in Tavnazian Safehold at (H-6) for a cutscene.
--   2. Choose to participate in voidwatch operations to receive the abyssite.
--   3. Defeat the four Voidwatch NMs in the Promathia areas.
--   4. Return to Owain to complete the quest.
--
-- The officer is a Voidwatch SERVICE COUNTER, not a per-quest NPC: one csid carries
-- the whole menu, where option 2 is "Participate in Voidwatch Ops." and option 3 is
-- "Request debriefing." Enrolment and the report-back therefore run through the same
-- event. scripts/globals/voidwatch_ops.lua holds the shared engine and the decode
-- notes, including how Camille and Owain data[] tables prove which abyssite each
-- chain awards.
--
-- Every notorious monster below was checked against sql/mob_groups.sql and sits in
-- exactly the zone bg-wiki names for it.
-----------------------------------
require('scripts/globals/voidwatch_ops')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_026_TAVNAZIAN_TERRORS)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.TAVNAZIAN_SAFEHOLD,
        name     = 'Owain',
        menuCsid = 628,
        postCsid = 630,
    },

    abyssite = xi.ki.HYACINTH_STRATUM_ABYSSITE,

    targets =
    {
        { zone = xi.zone.ATTOHWA_CHASM, mob = 'Fjalar' },
        { zone = xi.zone.LUFAISE_MEADOWS, mob = 'Abununnu' },
        { zone = xi.zone.MISAREAUX_COAST, mob = 'Tsui-Goab' },
        { zone = xi.zone.ULEGUERAND_RANGE, mob = 'Isarukitsck' },
    },
})

return quest
