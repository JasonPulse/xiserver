-----------------------------------
-- Release the Fleece
-----------------------------------
-- Log ID: 4, Quest ID: 123
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Chacharoon         : Mog Garden, entity 17924231
-- !addquest 4 123
-----------------------------------
-- Retail (bg-wiki "Release the Fleece").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Previous=None
-- |Next=Feeding Frenzy
-- |Quest Reqs=Recruit Susuroon at least once / Level 4 Mog Garden
-- |Reward=Chacharoon unlocked, Monster Rearing partially unlocked
--   1. "Simply speak to your Green Thumb Moogle for a cutscene involving Chacharoon."
--   2. "After the cutscene speak to Chacharoon to begin raising your first monster,
--      a baby sheep. Speak with Chacharoon again."
--   3. "Interact with your baby sheep. Your baby sheep likes to be pet."
--   4. "Speak with Chacharoon again who tells you to go speak with the Green Thumb
--      Moogle for a cutscene. This ends the quest and begins the next quest."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2044  DIRECTOR 17924176   msgs 8079-8113  the arrival cutscene
--   2047  Chacharoon 17924231 msgs 8114-8115  "Talk to sheep good."
--   2048  Chacharoon 17924231 msgs 8116-8117  "Chief, tell moogle of Chacharoon's
--                                              graaand feat!"
--   2045  DIRECTOR 17924176   msgs 8118-8161  the crab attack, ending on Chacharoon
--                                              asking for La Theine cabbage, which
--                                              is Feeding Frenzy's own first line
--
-- Every id above was read out of the event program's own data table rather than
-- attributed by position; see the header of scripts/globals/monster_rearing.lua.
-- All four were then fired at the puppet and the text read back:
--   2044 -> "Hidey ho, <name>!" / "Is no peace! Is chaooos!" / "Big scarebeasts
--           stalk beaches and forest around garden with beady eyes!"
--   2047 -> "Talk to sheep good. It like peeeople voice." / "Dooo what can."
--   2048 -> "...Everything go in-ear and stay in-ear?" / "Chief, tell moogle of
--           Chacharoon's graaand feat!"
--   2045 -> "Greetings, <name>! ...I thought sheltering that sheep would shroud
--           this shire in shenanigans" / "Could those really be...the frightening
--           fiends of fable?" / "I remember now, kupo!"
--
-- THE ONE PREREQUISITE THAT IS NOT CHECKED. bg-wiki also asks that Susuroon has
-- been recruited at least once. The Mog Garden assistants are not implemented on
-- this server, so there is nothing to read; the garden rank half of the gate is
-- checked in full.
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.RELEASE_THE_FLEECE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                xi.monsterRearing.eligible(player)
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2044)
                end,
            },

            onEventFinish =
            {
                [2044] = function(player, csid, option, npc)
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
            ['Chacharoon'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Released') == 0 then
                        return quest:progressEvent(2047)
                    end

                    if
                        xi.monsterRearing.careCount(player) > 0 and
                        quest:getVar(player, 'Reported') == 0
                    then
                        return quest:progressEvent(2048)
                    end

                    return quest:event(2047)
                end,
            },

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Reported') == 0 then
                        return
                    end

                    return quest:progressEvent(2045)
                end,
            },

            onEventFinish =
            {
                [2047] = function(player, csid, option, npc)
                    if xi.monsterRearing.grantCreature(player, 1) then
                        quest:setVar(player, 'Released', 1)
                    end
                end,

                [2048] = function(player, csid, option, npc)
                    quest:setVar(player, 'Reported', 1)
                end,

                [2045] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        -- "This ends the quest and begins the next quest." 2045's
                        -- closing line IS Feeding Frenzy's request, so the next
                        -- quest has no opening scene of its own.
                        player:addQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FEEDING_FRENZY)
                    end
                end,
            },
        },
    },
}

return quest
