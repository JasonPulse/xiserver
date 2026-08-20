-----------------------------------
-- VW Op. 068: Subterranean Skirmish
-----------------------------------
-- Log ID: 6, Quest ID: 69
-- Camille : Wajaom Woodlands (M-7), entity 16986829
-- !addquest 6 69
-----------------------------------
-- Retail (bg-wiki "VW Op. 068: Subterranean Skirmish").
-- |Start=Camille, Wajaom Woodlands  |Previous=VW Op. 050: Aht Urhgan Assault
-- |Reward=Amber stratum abyssite II  |Fame=Treasures of Aht Urhgan
--   1. Speaking with Camille at the end of the previous quest upgrades the
--      abyssite to Amber stratum abyssite II.
--   2. Defeat Morta in Aydeewa Subterrane.
--   3. Return to Camille to complete the quest.
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

local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.VW_OP_068_SUBTERRAINEAN_SKIRMISH)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.WAJAOM_WOODLANDS,
        name     = 'Camille',
        menuCsid = 628,
        postCsid = 630,
    },

    abyssite = xi.ki.AMBER_STRATUM_ABYSSITE_II,
    previous = { xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.VW_OP_050_AHT_URGAN_ASSAULT },

    targets =
    {
        { zone = xi.zone.AYDEEWA_SUBTERRANE, mob = 'Morta' },
    },
})

return quest
