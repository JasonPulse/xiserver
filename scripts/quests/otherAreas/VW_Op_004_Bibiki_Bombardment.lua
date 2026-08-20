-----------------------------------
-- VW Op. 004: Bibiki Bombardment
-----------------------------------
-- Log ID: 4, Quest ID: 85
-- Owain : Tavnazian Safehold (H-6), entity 16883890
-- !addquest 4 85
-----------------------------------
-- Retail (bg-wiki "VW Op. 004: Bibiki Bombardment").
-- |Start=Owain, Tavnazian Safehold  |Previous=VW Op. 026: Tavnazian Terrors
-- |Reward=Hyacinth stratum abyssite II  |Fame=Other
--   1. Speaking with Owain at the end of the previous quest upgrades the
--      abyssite and automatically begins this one.
--   2. Defeat Bismarck in Bibiki Bay (Purgonorgo Isle).
--   3. Return to Owain to complete the quest.
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

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_004_BIBIKI_BOMBARDMENT)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.TAVNAZIAN_SAFEHOLD,
        name     = 'Owain',
        menuCsid = 628,
        postCsid = 630,
    },

    abyssite = xi.ki.HYACINTH_STRATUM_ABYSSITE_II,
    previous = { xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_026_TAVNAZIAN_TERRORS },

    targets =
    {
        { zone = xi.zone.BIBIKI_BAY, mob = 'Bismarck' },
    },
})

return quest
