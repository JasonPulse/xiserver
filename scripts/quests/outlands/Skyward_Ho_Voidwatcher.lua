-----------------------------------
-- Skyward Ho, Voidwatcher!
-----------------------------------
-- Log ID: 7, Quest ID: 104
-- Kieran : Norg (H-8), entity 17809529
-- !addquest 7 104
-----------------------------------
-- Retail (bg-wiki "Skyward Ho, Voidwatcher!").
-- |Start=Kieran, Norg  |Previous=VW Op. 115: Li Telor Variant
--   1. After completing the previous quest and receiving the Ashen stratum
--      abyssite III from Kieran, this quest is flagged automatically.
--   2. Complete the three Tier III Voidwatch battles in the Tu Lia region:
--      Aello, Qilin and Uptala.
--   3. Return to Norg and speak to Kieran.
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

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.SKYWARD_HO_VOIDWATCHER)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.NORG,
        name     = 'Kieran',
        menuCsid = 259,
        postCsid = 261,
    },

    previous = { xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_115_LI_TELOR_VARIANT },

    targets =
    {
        { zone = xi.zone.RUAUN_GARDENS, mob = 'Aello' },
        { zone = xi.zone.THE_SHRINE_OF_RUAVITAU, mob = 'Qilin' },
        { zone = xi.zone.VELUGANNON_PALACE, mob = 'Uptala' },
    },
})

return quest
