-----------------------------------
-- VW Op. 050: Aht Urhgan Assault
-----------------------------------
-- Log ID: 6, Quest ID: 68
-- Camille : Wajaom Woodlands (M-7), entity 16986829
-- !addquest 6 68
-----------------------------------
-- Retail (bg-wiki "VW Op. 050: Aht Urhgan Assault").
-- |Start=Camille, Wajaom Woodlands  |Fame=Treasures of Aht Urhgan
-- |Quest Reqs=Adventurer Certificate, Level 75 or higher  |Reward=Amber stratum abyssite
--   1. Speak with Camille in Wajaom Woodlands at (M-7) for a cutscene.
--   2. Choose to participate in voidwatch operations to receive the abyssite.
--   3. Defeat the four Voidwatch NMs in the Aht Urhgan areas.
--   4. Return to Camille to complete the quest.
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

local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.VW_OP_050_AHT_URGAN_ASSAULT)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.WAJAOM_WOODLANDS,
        name     = 'Camille',
        menuCsid = 628,
        postCsid = 630,
    },

    abyssite = xi.ki.AMBER_STRATUM_ABYSSITE,

    targets =
    {
        { zone = xi.zone.ARRAPAGO_REEF, mob = 'Dimgruzub' },
        { zone = xi.zone.CAEDARVA_MIRE, mob = 'Brekekekex' },
        { zone = xi.zone.MAMOOK, mob = 'Yalungur' },
        { zone = xi.zone.MOUNT_ZHAYOLM, mob = 'Vanasarvik' },
    },
})

return quest
