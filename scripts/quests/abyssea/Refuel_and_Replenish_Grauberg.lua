-----------------------------------
-- Refuel and Replenish (Grauberg)
-----------------------------------
-- Log ID: 8, Quest ID: 150
-- Machine Outfitter : Grauberg Abyssea camp
-- !addquest 8 150
-----------------------------------
-- Retail (bg-wiki "Refuel and Replenish (Grauberg)").
-- |Start=Machine Outfitter (Grauberg), Abyssea - Grauberg
-- |Fame=agra |FLevel=1  |Repeatable=Yes
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

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.REFUEL_AND_REPLENISH_GRAUBERG)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_GRAUBERG,
}

quest.sections = xi.martelloOps.sections(quest,
{
    zone      = xi.zone.ABYSSEA_GRAUBERG,
    fameArea  = xi.fameArea.ABYSSEA_GRAUBERG,
    fameLevel = 1,
    mode      = xi.martelloOps.op.REFUEL,
    towers    =
    {
        'GR-01_Martello',
        'GR-02_Martello',
        'GR-03_Martello',
        'GR-04_Martello',
        'GR-05_Martello',
        'GR-06_Martello',
        'GR-07_Martello',
        'GR-08_Martello',
    },
})

return quest
