-----------------------------------
-- Chacharoon's Cheer
-----------------------------------
-- Log ID: 4, Quest ID: 126
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Chacharoon         : Mog Garden, entity 17924231
-- !addquest 4 126
-----------------------------------
-- Retail (bg-wiki "Chacharoon's Cheer").
-- |Start=Green Thumb Moogle, Mog Gardens  |Previous=Cry Not, Caretaker
-- |Next=Trial of the Chacharoon
-- |Quest Reqs="Sakura and the Magic Spoon"  |Item Reqs=Gold Beastcoin
-- |Reward=Ability to activate "Cheer" bonuses from Monster Rearing
--   1. "Upon reaching level 2 in Monster Rearing from obtaining the key item
--      'Sakura and the Magic Spoon' zone into your Mog Garden."
--   2. "Trade Chacharoon a Gold Beastcoin to complete the quest."
--   3. "You'll unlock the ability to 'Discuss a cheering effect.' with Chacharoon."
--   4. "You will automatically get Cheer: Lamb activated as part of completing
--      this quest."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2059  DIRECTOR 17924176   msgs 8232-8270  the zone-in scene, Susuroon asking
--                                        you to teach Chacharoon about jingly
--   2060  Green Thumb Moogle  msgs 8271-8272  "Give one <gold beastcoin> to
--                                        Chacharoon and holler that you need help"
--   2061  DIRECTOR 17924176   msgs 8273-8291  the turn-in, "Is that a <gold
--                                        beastcoin>?" through the first cheer
--
-- All three fired at the puppet and read back:
--   2059 -> "Aboook! Abooooook!" / "Could you've caught a calamitous cold, my
--           cuddly companion, kupo!?" / "No! Chacharoon taaalking about book."
--   2060 -> "Give one gold beastcoin to Chacharoon and holler that you need help
--           harvesting such a hearty haul, kupo."
--   2061 -> "Is that a gold beastcoin?"
--
-- Rank 2 is the gate, and rank is the sixth Mog Garden location, so it reads out
-- of the same locationRank the other five use.
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CHACHAROONS_CHEER)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CRY_NOT_CARETAKER) and
                xi.monsterRearing.rank(player) >= 2
        end,

        [xi.zone.MOG_GARDEN] =
        {
            onZoneIn = function(player, prevZone)
                return 2059
            end,

            onEventFinish =
            {
                [2059] = function(player, csid, option, npc)
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
                onTrigger = function(player, npc)
                    return quest:event(2060)
                end,
            },

            ['Chacharoon'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.GOLD_BEASTCOIN) then
                        return quest:progressEvent(2061)
                    end
                end,
            },

            onEventFinish =
            {
                [2061] = function(player, csid, option, npc)
                    if not quest:complete(player) then
                        return
                    end

                    player:confirmTrade()

                    -- "You will automatically get Cheer: Lamb activated as part of
                    -- completing this quest."
                    npcUtil.giveKeyItem(player, xi.ki.CHEER_LAMB)
                    xi.monsterRearing.setCheer(player, xi.ki.CHEER_LAMB)
                end,
            },
        },
    },
}

return quest
