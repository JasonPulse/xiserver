-----------------------------------
-- VW Op. 115: Li Telor Variant
-----------------------------------
-- Log ID: 7, Quest ID: 103
-- Kieran : Norg (I-8), entity 17809529
-- !addquest 7 103
-----------------------------------
-- Retail (bg-wiki "VW Op. 115: Li Telor Variant").
-- |Start=Kieran, Norg  |Previous=Voidwatch Ops: Border Crossing
-- |Reward=Ashen stratum abyssite III
--   1. Speak to Kieran in Norg.
--   2. Complete the three Tier II Voidwatch battles in the Li Telor region.
--   3. Return to Kieran to complete the quest.
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

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_115_LI_TELOR_VARIANT)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.NORG,
        name     = 'Kieran',
        menuCsid = 259,
        postCsid = 261,
    },

    abyssite = xi.ki.ASHEN_STRATUM_ABYSSITE_III,
    previous = { xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING },

    targets =
    {
        { zone = xi.zone.THE_SANCTUARY_OF_ZITAH, mob = 'Cath_Palug' },
        { zone = xi.zone.THE_BOYAHDA_TREE, mob = 'Modron' },
        { zone = xi.zone.ROMAEVE, mob = 'Mimic_King' },
    },
})

return quest
