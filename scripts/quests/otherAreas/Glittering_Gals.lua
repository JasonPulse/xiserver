-----------------------------------
-- Glittering Gals
-----------------------------------
-- Log ID: 4, Quest ID: 130
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 130
-----------------------------------
-- Retail (bg-wiki "Glittering Gals").
-- |Start=Green Thumb Moogle, Mog Garden  |Previous=Full Speed Ahead! /
--  Titillating Tomes / Rowing Together  |Next=Sally Forth!
-- |Title=Gardener for the Ages  |Reward=Sheep companion
--   1. "Speak with Green Thumb Moogle for a cutscene. You do not need to zone
--      following completing the other quests."
--   2. "He will ask for you to plant the Fruit Seeds he gives you along with
--      Sunsand as fertilizer."
--   3. "Harvest or obtain a Tropical Cactus and trade it to Green Thumb Moogle for
--      a final cutscene."
--   "You can purchase a Tropical Cactus directly off the AH under Others > Misc to
--    skip any waiting on harvesting or having to obtain a Sunsand."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2036  DIRECTOR3 17924201  msgs 7883-7921  the arrival of the troupe, ending on
--                                        "fetch some fertilizer! <Sunsand> will do
--                                        just fine" and "Let's do this!"
--   2035  Green Thumb Moogle  msgs 7922-7923  "Grow some crab chow and show those
--                                        strange girls what a green thumb really
--                                        means!"
--   2037  DIRECTOR3 17924201  msgs 7924-7948  the turn-in, "You got...<tropical
--                                        cactus>? What's that, kupo?"
--
-- 2076 IS SALLY FORTH'S OPENER, NOT THIS QUEST'S. The three were fired at the
-- puppet and the client settles it in its own words:
--   2036 -> "Gadzooks! There's a googol of girls here, kupo!"
--   2035 -> "Grow some crab chow and show those strange girls what a green thumb
--           really means!" / "Sow the bag of fruit seeds into the ground and apply
--           the pinch of Valkurm sunsand to help it grow, kupo!"
--   2037 -> "You got...a tropical cactus? What's that, kupo?"
-- while 2076 renders "Hmmm...where could those wistful ones be?" and goes on to
-- ask for a flask of Grow-M-Good, which is Sally Forth's item. bg-wiki splits the
-- two quests on exactly those items.
--
-- THE ONE PREREQUISITE THAT IS CHECKED SIDEWAYS. bg-wiki asks for Titillating
-- Tomes, which is not built on this server. Its whole content is "Must have level
-- 7 in all Geological Locations", so that is what is checked instead of the quest
-- flag. The moment Titillating Tomes lands, this gate is already satisfied by
-- anyone who could have finished it.
-----------------------------------
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.GLITTERING_GALS)

quest.reward =
{
    keyItem = xi.ki.SHEEP_COMPANION,
    title   = xi.title.GARDENER_FOR_THE_AGES,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ROWING_TOGETHER) and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.FULL_SPEED_AHEAD) and
                xi.mog_garden.allLocationsMaxRank(player)
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2036)
                end,
            },

            onEventFinish =
            {
                [2036] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveItem(player, xi.item.BAG_OF_FRUIT_SEEDS)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.TROPICAL_CACTUS) then
                        return quest:progressEvent(2037)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(2035)
                end,
            },

            onEventFinish =
            {
                [2037] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
