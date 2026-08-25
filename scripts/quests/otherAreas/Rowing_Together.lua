-----------------------------------
-- Rowing Together
-----------------------------------
-- Log ID: 4, Quest ID: 129
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Chacharoon         : Mog Garden, entity 17924231
-- Chacharoon         : Mog Garden rearing grounds, entity 17924232
-- Stinknix           : Lower Jeuno, entity 17780841
-- !addquest 4 129
-----------------------------------
-- Retail (bg-wiki "Rowing Together").
-- |Start=Green Thumb Moogle, Mog Garden  |Previous=Doctor Chacharoon
-- |Next=Glittering Gals  |Quest Reqs="Sakura and the Holy Grail"
-- |Title=Serious Snuggler  |Reward=Thatch Boots
--   1. "Continue monster rearing and purchase the key item 'Sakura and the Holy
--      Grail' (Interact ~100 times)."
--   2. "Enter your Mog Garden for a cutscene."
--   3. "Head to Muckvix's Junk Shop in Lower Jeuno at (H-9) and speak to Stinknix
--      for a cutscene and the KI: Chacharoon's sack of supplies."
--   4. "Speak to Chacharoon not in the main area of your Mog Garden but in the
--      Rearing Grounds for a cutscene and your rewards."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2071  DIRECTOR2 17924188  msgs 8468-8494  the zone-in scene
--   2072  Green Thumb Moogle  msgs 8495-8497  "Head to the Goblins' shop in Lower
--                                        Jeuno for supplies."
--  20070  qm1 17780811        msgs 10963-10992  the Lower Jeuno scene, ending on
--                                        "This is what li'l Chacharoon always
--                                        gets", which is the sack of supplies.
--                                        Held on the zone's hidden ??? entity the
--                                        same way DIRECTOR holds the garden's.
--   2073  Green Thumb Moogle  msg 8498  "Just drop them off in the rearing grounds
--                                        out back, kupo."
--   2074  Chacharoon 17924231 msgs 8499-8500  "Let's take these creature-crunchies
--                                        to the back-cave rearing place."
--   2075  DIRECTOR2 17924188  msgs 8501-8521  the reward scene in the rearing
--                                        grounds
--
-- All six fired at the puppet and read back:
--   2071  -> "Let us ascertain at once what this 'Sakura and the Holy Grail'
--            advocates for the accommodation of additional animals!", which names
--            the rank 7 book this quest gates on
--   2072  -> "Head to the Goblins' shop in Lower Jeuno for supplies."
--  20070  -> "Hey, did Chacharoon send ya? Here fo' the usual?" and on through
--            Susuroon and the watering can
--   2073  -> "Superb! You've returned with the supplies!"
--   2074  -> "Chief go all the faraway-way to Jeuno? Biiiiiig thank you!"
--   2075  -> "Chacharoon give big thanking, Chief!" / "Team Su-Charoon best team!"
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.ROWING_TOGETHER)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.DOCTOR_CHACHAROON) and
                xi.monsterRearing.rank(player) >= 7
        end,

        [xi.zone.MOG_GARDEN] =
        {
            onZoneIn = function(player, prevZone)
                return 2071
            end,

            onEventFinish =
            {
                [2071] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Stinknix'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CHACHAROONS_SACK_OF_SUPPLIES) then
                        return
                    end

                    return quest:progressEvent(20070)
                end,
            },

            onEventFinish =
            {
                [20070] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.CHACHAROONS_SACK_OF_SUPPLIES)
                end,
            },
        },

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.CHACHAROONS_SACK_OF_SUPPLIES) then
                        return quest:event(2072)
                    end

                    return quest:event(2073)
                end,
            },

            ['Chacharoon'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.CHACHAROONS_SACK_OF_SUPPLIES) then
                        return quest:event(2072)
                    end

                    if npc:getID() == xi.monsterRearing.npc.CHACHAROON_GARDEN then
                        return quest:event(2074)
                    end

                    return quest:progressEvent(2075)
                end,
            },

            onEventFinish =
            {
                [2075] = function(player, csid, option, npc)
                    -- Thatch Boots come in a male and a female cut, the female id one
                    -- above the male, and getGender() is 0 for male.
                    if not npcUtil.giveItem(player, xi.item.THATCH_BOOTS_M + player:getGender()) then
                        return
                    end

                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.CHACHAROONS_SACK_OF_SUPPLIES)
                        player:addTitle(xi.title.SERIOUS_SNUGGLER)
                    end
                end,
            },
        },
    },
}

return quest
