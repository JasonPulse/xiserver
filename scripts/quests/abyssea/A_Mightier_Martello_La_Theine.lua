-----------------------------------
-- A Mightier Martello (La Theine)
-----------------------------------
-- Log ID: 8, Quest ID: 151
-- Machine Outfitter : La Theine Abyssea camp
-- !addquest 8 151
-----------------------------------
-- Retail (bg-wiki "A Mightier Martello (La Theine)").
-- |Start=Machine Outfitter (La Theine), Abyssea - La Theine
-- |Fame=alth |FLevel=3  |Repeatable=Yes
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

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_MIGHTIER_MARTELLO_LA_THEINE)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_LATHEINE,
}

quest.sections = xi.martelloOps.sections(quest,
{
    zone      = xi.zone.ABYSSEA_LA_THEINE,
    fameArea  = xi.fameArea.ABYSSEA_LATHEINE,
    fameLevel = 3,
    mode      = xi.martelloOps.op.UPGRADE,
    towers    =
    {
        'LT-01_Martello',
        'LT-02_Martello',
        'LT-03_Martello',
        'LT-04_Martello',
        'LT-05_Martello',
        'LT-06_Martello',
        'LT-07_Martello',
        'LT-08_Martello',
    },
})

return quest
