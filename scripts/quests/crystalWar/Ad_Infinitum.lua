-----------------------------------
-- Ad Infinitum
-----------------------------------
-- Log ID: 7, Quest ID: 98
-- !addquest 7 98
-----------------------------------
-- Retail (bg-wiki "Ad Infinitum").
-- Step nineteen and last of the Wings of the Goddess Voidwatch storyline
-- (80..98, in id order).
-- |Previous=Endings and Beginnings  |Next=(none)
--   "This quest marks completion of the Voidwatch storyline, but cannot be
--    'completed' and will always remain in the 'Current Quests' menu in-game."
--
-- THAT IS THE WHOLE QUEST, and it is why this file has no sections. Ad Infinitum is
-- flagged by the previous step and is deliberately never completed: it is a permanent
-- entry in the player's current-quests list marking that the storyline is finished.
-- There is nothing to trigger, nothing to trade and no reward to hand out, so adding
-- handlers would be inventing content the quest does not have.
--
-- Endings and Beginnings completes itself and, per bg-wiki, "begins the next quest",
-- which is this one. The Quest object exists so that flagging it resolves to a real
-- entry rather than a bare id.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.AD_INFINITUM)

quest.sections = {}

return quest
