-----------------------------------
-- VW Op. 101: Detour to Zepwell
-----------------------------------
-- Log ID: 7, Quest ID: 102
-- Gushing_Spring : Rabao (G-8), entity 17789012
-- !addquest 7 102
-----------------------------------
-- Retail (bg-wiki "VW Op. 101: Detour to Zepwell").
-- |Start=Gushing Spring, Rabao (G-8)  |Previous=Voidwatch Ops: Border Crossing
--   1. After starting Border Crossing and receiving the Ashen stratum abyssite,
--      speak to Gushing Spring in Rabao.
--   2. Complete the three Tier I Voidwatch battles in the Zepwell region.
--   3. Return to Gushing Spring to complete the quest.
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

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_101_DETOUR_TO_ZEPWELL)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.RABAO,
        name     = 'Gushing_Spring',
        menuCsid = 13,
        postCsid = 15,
    },

    previous = { xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING },

    targets =
    {
        { zone = xi.zone.WESTERN_ALTEPA_DESERT, mob = 'Sabotender_Campeador' },
        { zone = xi.zone.QUICKSAND_CAVES, mob = 'Malleator_Maurok' },
        { zone = xi.zone.KUFTAL_TUNNEL, mob = 'Tangaroa' },
    },
})

return quest
