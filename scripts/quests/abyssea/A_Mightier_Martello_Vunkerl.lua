-----------------------------------
-- A Mightier Martello (Vunkerl)
-----------------------------------
-- Log ID: 8, Quest ID: 156
-- Machine Outfitter : Vunkerl Abyssea camp
-- !addquest 8 156
-----------------------------------
-- Retail (bg-wiki "A Mightier Martello (Vunkerl)").
-- |Start=Machine Outfitter (Vunkerl), Abyssea - Vunkerl
-- |Fame=avun |FLevel=2  |Repeatable=Yes
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
--
-- bg-wiki's page for this one prints Fame=aatt, which is a typo: it is the Vunkerl
-- quest and every other Vunkerl entry uses avun. ABYSSEA_VUNKERL is used here.
-----------------------------------
require('scripts/globals/abyssea/martello_ops')
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.A_MIGHTIER_MARTELLO_VUNKERL)

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

quest.sections = xi.martelloOps.sections(quest,
{
    zone      = xi.zone.ABYSSEA_VUNKERL,
    fameArea  = xi.fameArea.ABYSSEA_VUNKERL,
    fameLevel = 2,
    mode      = xi.martelloOps.op.UPGRADE,
    towers    =
    {
        'VK-01_Martello',
        'VK-02_Martello',
        'VK-03_Martello',
        'VK-04_Martello',
        'VK-05_Martello',
        'VK-06_Martello',
        'VK-07_Martello',
        'VK-08_Martello',
    },
})

return quest
