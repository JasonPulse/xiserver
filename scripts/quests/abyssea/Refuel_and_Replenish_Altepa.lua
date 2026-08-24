-----------------------------------
-- Refuel and Replenish (Altepa)
-----------------------------------
-- Log ID: 8, Quest ID: 148
-- Machine Outfitter : Altepa Abyssea camp
-- !addquest 8 148
-----------------------------------
-- Retail (bg-wiki "Refuel and Replenish (Altepa)").
-- |Start=Machine Outfitter (Altepa), Abyssea - Altepa
-- |Fame=aalt |FLevel=1  |Repeatable=Yes
-- |Reward=Varying amount of Cruor depending on which Martello you choose.
--   1. "Speak to the Machine Outfitter near the entrance of zone, and choose
--      'Assist with replenishment' to accept the quest."
--   2. "You will receive KI Vat of martello fuel."
--      "You cannot zone at any point during the quest, or you lose the key item and
--       you must restart."
--   3. "Find a Martello in the zone." "It is possible to replenish it even if it is
--      already at 100%."
--   4. "Although not told to you, the KI Vat of martello fuel is replaced with an KI Empty fuel vat."
--   5. "Report to the Machine Outfitter to complete the quest."
--   "Only one Refuel and Replenish or A Mightier Martello quest can be completed per
--    Vana'dielian day, regardless of Abyssea area."
--
-- All eighteen martello operation quests share one implementation; the walkthrough,
-- the shared daily limit, the decoded tower menu and the reason this drives the
-- towers with printToPlayer rather than that menu are all documented in
-- scripts/globals/abyssea/martello_ops.lua. This file is only the zone's spec.
-----------------------------------
require('scripts/globals/abyssea/martello_ops')
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.REFUEL_AND_REPLENISH_ALTEPA)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

quest.sections = xi.martelloOps.sections(quest,
{
    zone      = xi.zone.ABYSSEA_ALTEPA,
    fameArea  = xi.fameArea.ABYSSEA_ALTEPA,
    fameLevel = 1,
    mode      = xi.martelloOps.op.REFUEL,
    towers    =
    {
        'AL-01_Martello',
        'AL-03_Martello',
        'AL-04_Martello',
        'AL-05_Martello',
        'AL-06_Martello',
        'AL-07_Martello',
        'AL-08_Martello',
    },
})

return quest
