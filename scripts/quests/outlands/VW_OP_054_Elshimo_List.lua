-----------------------------------
-- VW Op. 054: Elshimo List
-----------------------------------
-- Log ID: 7, Quest ID: 101
-- Hildegard : Kazham (F-8), entity 17801352
-- !addquest 7 101
-----------------------------------
-- Retail (bg-wiki "VW Op. 054: Elshimo List").
-- |Start=Hildegard, Kazham (F-8)  |Previous=Voidwatch Ops: Border Crossing
--   1. After starting Border Crossing and receiving the Ashen stratum abyssite,
--      speak to Hildegard in Kazham.
--   2. Complete the three Tier I Voidwatch battles in the Elshimo region:
--        Holy Moly    -- Yuhtunga Jungle
--        Neith        -- Temple of Uggalepih
--        Ildebrann    -- Ifrit's Cauldron
--   3. Return to Hildegard to complete the quest.
--
-- THIS FILE REPLACES A STUB. The previous version carried the header comment
-- "VW not yet implemented; stub accepts and immediately completes until VW Lite is
-- built" and did exactly that -- it handed the quest straight back as complete
-- without any of the three battles. The Voidwatch NMs it names all exist in
-- sql/mob_groups.sql, in exactly the zones bg-wiki lists, so the real flow is
-- buildable and the stub is no longer needed.
--
-- The officer is a Voidwatch SERVICE COUNTER, not a per-quest NPC: one csid carries
-- the whole menu, where option 2 is "Participate in Voidwatch Ops." and option 3 is
-- "Request debriefing." Enrolment and the report-back therefore run through the same
-- event. scripts/globals/voidwatch_ops.lua holds the shared engine and the decode
-- notes. Hildegard's counter is csid 313, with 315 as her post-completion line.
--
-- No abyssite is granted here: Border Crossing hands over the Ashen stratum
-- abyssite, and this subquest checks for that quest rather than re-issuing it.
-----------------------------------
require('scripts/globals/voidwatch_ops')
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_054_ELSHIMO_LIST)

quest.sections = xi.voidwatch.opSections(quest,
{
    giver =
    {
        zone     = xi.zone.KAZHAM,
        name     = 'Hildegard',
        menuCsid = 313,
        postCsid = 315,
    },

    previous = { xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING },

    targets =
    {
        { zone = xi.zone.YUHTUNGA_JUNGLE,     mob = 'Holy_Moly' },
        { zone = xi.zone.TEMPLE_OF_UGGALEPIH, mob = 'Neith' },
        { zone = xi.zone.IFRITS_CAULDRON,     mob = 'Ildebrann' },
    },
})

return quest
