-----------------------------------
-- Feeding Frenzy
-----------------------------------
-- Log ID: 4, Quest ID: 124
-- Chacharoon : Mog Garden, entity 17924231
-- !addquest 4 124
-----------------------------------
-- Retail (bg-wiki "Feeding Frenzy").
-- |Start=Green Thumb Moogle, Mog Garden  |Previous=Release the Fleece
-- |Next=Cry Not, Caretaker  |Quest Reqs=La Theine Cabbage
--   1. "Chacharoon asks you to feed your baby sheep some La Theine Cabbage. You
--      cannot continue raising your sheep until this is done."
--   2. "Feed (trade) the sheep the La Theine Cabbage."
--   3. "Leave your Mog Garden and then return to it, for a cutscene. This ends the
--      quest and begins the next quest, Cry Not, Caretaker."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2055  Chacharoon 17924231 msg 8161  "Chief can get <La Theine cabbage> for
--                                        Chacharoon and feed to scaaaredy lamb?"
--   2056  Chacharoon 17924231 msg 8162  "...Chacharoon be gloating to moogle in
--                                        soon-times."
--   2046  DIRECTOR 17924176   msgs 8163-8192  the zone-in cutscene where the lamb
--                                        dies and the cotton thread is asked for
--
-- All three fired at the puppet and read back:
--   2055 -> "Chief can get La Theine cabbage for Chacharoon and feed to scaaaredy
--           lamb?", which also confirms the item the step wants
--   2056 -> "<name> so very much loving! ...Chacharoon be gloating to moogle in
--           soon-times."
--   2046 -> "A baleful blight has befallen this beautiful base, kupo!" / "We were
--           overrun by an onslaught of obscure crabs" / "Sheep...die...to saaave
--           meee!" and on into Atelloune's lecture
--
-- The quest opens with no cutscene of its own because Release the Fleece's closing
-- scene already ends on 8161, which is this quest's request.
--
-- WHY THE FEED IS WATCHED THROUGH A CHARVAR RATHER THAN THE TRADE. The pen's own
-- onTrade handler confirms the trade, and the framework runs every matching
-- handler in one pass, so a second handler reading trade:getItemId() would race an
-- already emptied container. xi.monsterRearing records what was last fed instead.
-----------------------------------
require('scripts/globals/monster_rearing')
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FEEDING_FRENZY)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Chacharoon'] =
            {
                onTrigger = function(player, npc)
                    if xi.monsterRearing.lastFedItem(player) ~= xi.item.LA_THEINE_CABBAGE then
                        return quest:event(2055)
                    end

                    if quest:getVar(player, 'Fed') == 0 then
                        return quest:progressEvent(2056)
                    end

                    return quest:event(2056)
                end,
            },

            -- "Leave your Mog Garden and then return to it, for a cutscene."
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Fed') == 0 then
                    return
                end

                return 2046
            end,

            onEventFinish =
            {
                [2056] = function(player, csid, option, npc)
                    quest:setVar(player, 'Fed', 1)
                end,

                [2046] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CRY_NOT_CARETAKER)
                    end
                end,
            },
        },
    },
}

return quest
