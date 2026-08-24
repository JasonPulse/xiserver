-----------------------------------
-- A Mightier Martello (Attohwa)
-----------------------------------
-- Log ID: 8, Quest ID: 154
-- Machine Outfitter : Attohwa Abyssea camp
-- !addquest 8 154
-----------------------------------
-- Retail (bg-wiki "A Mightier Martello (Attohwa)").
-- |Start=Machine Outfitter (Attohwa), Abyssea - Attohwa
-- |Fame=aatt |FLevel=3  |Repeatable=Yes
-- |Reward=Varying amount of Cruor depending on the direction the upgrade is completed from.
--   1. "Speak to the Machine Outfitter near the entrance of zone, and choose
--      'Assist with upgrades' to accept the quest."
--   2. "You will receive KI Fuel reservoir."
--      "You cannot zone at any point during the quest, or you lose the key item and
--       you must restart."
--   3. "Find a Martello in the zone." "It is possible to upgrade it even if it is
--      already at 100%."
--   4. "Although not told to you, the KI Fuel reservoir is replaced with an KI Cracked fuel reservoir."
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

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_MIGHTIER_MARTELLO_ATTOHWA)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ATTOHWA,
}

quest.sections = xi.martelloOps.sections(quest,
{
    zone      = xi.zone.ABYSSEA_ATTOHWA,
    fameArea  = xi.fameArea.ABYSSEA_ATTOHWA,
    fameLevel = 3,
    mode      = xi.martelloOps.op.UPGRADE,
    towers    =
    {
        'AT-01_Martello',
        'AT-02_Martello',
        'AT-03_Martello',
        'AT-04_Martello',
        'AT-05_Martello',
        'AT-06_Martello',
        'AT-07_Martello',
        'AT-08_Martello',
    },
})

return quest
