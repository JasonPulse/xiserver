-----------------------------------
-- Doctor Chacharoon
-----------------------------------
-- Log ID: 4, Quest ID: 128
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 128
-----------------------------------
-- Retail (bg-wiki "Doctor Chacharoon").
-- |Start=Chacharoon, Mog Garden  |Previous=Trial of the Chacharoon
-- |Next=Rowing Together
-- |Quest Reqs="Sakura's Excellent Adventure" / Crayfish x12
-- |Reward=Work Gloves, matching the character's gender
--   1. "Continue monster rearing and purchase the key item 'Sakura's Excellent
--      Adventure'."
--   2. "Enter your Mog Garden for a cutscene."
--   3. "Trade 12 Crayfish to your Green Thumb Moogle to complete the quest."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2068  DIRECTOR2 17924188  msgs 8393-8416  the zone-in scene, the sickly
--                                        adamantoise hatchling washed ashore
--   2069  Green Thumb Moogle  msgs 8417-8418  "Bring me twelve <crayfish> so that
--                                        I can brew the best bisque"
--   2070  DIRECTOR2 17924188  msgs 8419-8467  the turn-in
--
-- All three fired at the puppet and read back:
--   2068 -> "An entirely anomalous article has alighted on our shore, kupo!"
--   2069 -> "Bring me twelve crayfish so that I can brew the best bisque"
--   2070 -> "These perky prawns will be perfect!" / "Soup tasty goood?"
--
-- Rank 5 is the gate. bg-wiki adds that "once the quest is activated, you will
-- automatically receive the rank 5 promotion", which is its way of saying the
-- promotion and the quest both hang off buying the book; the book is what the
-- rank is read from, so nothing is granted here.
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.DOCTOR_CHACHAROON)

local crayfishNeeded = 12

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_OF_THE_CHACHAROON) and
                xi.monsterRearing.rank(player) >= 5
        end,

        [xi.zone.MOG_GARDEN] =
        {
            onZoneIn = function(player, prevZone)
                return 2068
            end,

            onEventFinish =
            {
                [2068] = function(player, csid, option, npc)
                    quest:begin(player)
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
                    if trade:hasItemQty(xi.item.CRAYFISH_1, crayfishNeeded) then
                        return quest:progressEvent(2070)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(2069)
                end,
            },

            onEventFinish =
            {
                [2070] = function(player, csid, option, npc)
                    -- Work Gloves come in a male and a female cut, the female id one
                    -- above the male, and getGender() is 0 for male. Handed over here
                    -- rather than through quest.reward so the id can depend on the
                    -- player without mutating a table the container shares.
                    if not npcUtil.giveItem(player, xi.item.WORK_GLOVES_M + player:getGender()) then
                        return
                    end

                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
