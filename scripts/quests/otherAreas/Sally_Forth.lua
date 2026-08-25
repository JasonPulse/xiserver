-----------------------------------
-- Sally Forth!
-----------------------------------
-- Log ID: 4, Quest ID: 131
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 131
-----------------------------------
-- Retail (bg-wiki "Sally Forth!").
-- |Start=Green Thumb Moogle, Mog Garden  |Previous=Glittering Gals  |Next=None
-- |Item Reqs=Grow-M-Good  |Title=Lagoon Explorer  |Reward=Morbol companion
--   1. "You must zone after completing Glittering Gals to start this quest."
--   2. "Speak with Green Thumb Moogle for a cutscene, he will ask for
--      Grow-M-Good."
--   3. "Speak with him again for some reminder text."
--   4. "Trade the Green Thumb Moogle the Grow-M-Good for a final cutscene."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2076  DIRECTOR3 17924201  msgs 7949-7953  the opening, "Would you mind
--                                        bringing me <Grow-M-Good>?"
--   2038  Green Thumb Moogle  msgs 7954-7955  "I require <Grow-M-Good> so that the
--                                        plants grow straight and strong, kupo!"
--                                        and the flowers line
--   2039  DIRECTOR3 17924201  msgs 7956-8010  the turn-in, ending on "This <morbol>
--                                        for you."
--
-- All three fired at the puppet and read back:
--   2076 -> "Hmmm...where could those wistful ones be? It's been so long since
--           they visited, kupo." and on to the Grow-M-Good request
--   2038 -> "I require a flask of Grow-M-Good so that the plants grow straight and
--           strong, kupo!"
--   2039 -> "Splendid! I was waiting for a flask of Grow-M-Good!"
--
-- 2076 opens THIS quest, not Glittering Gals: the brief filed it under Glittering
-- Gals, but the client asks for Grow-M-Good in it, and Glittering Gals wants a
-- tropical cactus. See that file's header.
--
-- "You must zone after completing Glittering Gals to start this quest" is why the
-- opener is gated on a zone-in flag rather than firing the moment the previous
-- quest closes.
-----------------------------------
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.SALLY_FORTH)

quest.reward =
{
    keyItem = xi.ki.MORBOL_COMPANION,
    title   = xi.title.LAGOON_EXPLORER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.GLITTERING_GALS)
        end,

        [xi.zone.MOG_GARDEN] =
        {
            -- The zone-in only arms the moogle; retail still wants the player to
            -- speak to him for the cutscene.
            onZoneIn = function(player, prevZone)
                quest:setVar(player, 'Zoned', 1)
            end,

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Zoned') == 0 then
                        return
                    end

                    return quest:progressEvent(2076)
                end,
            },

            onEventFinish =
            {
                [2076] = function(player, csid, option, npc)
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
                    if npcUtil.tradeHasExactly(trade, xi.item.FLASK_OF_GROW_M_GOOD) then
                        return quest:progressEvent(2039)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(2038)
                end,
            },

            onEventFinish =
            {
                [2039] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
