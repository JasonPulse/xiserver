-----------------------------------
-- Cry Not, Caretaker
-----------------------------------
-- Log ID: 4, Quest ID: 125
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- Chacharoon         : Mog Garden, entity 17924231
-- !addquest 4 125
-----------------------------------
-- Retail (bg-wiki "Cry Not, Caretaker").
-- |Start=Green Thumb Moogle, Mog Garden  |Previous=Feeding Frenzy
-- |Next=Chacharoon's Cheer  |Quest Reqs=Cotton Thread  |Title=Sublime Slicer
-- |Reward=Lamb memento, Roast Mutton, fully unlock Monster Rearing
--   1. "Trade a Cotton Thread to the Green Thumb Moogle for a cutscene and to
--      complete the quest."
--
-- CSIDS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
--   2058  Chacharoon 17924231 msg 8193  "Please be paaassing <cotton thread> to
--                                        moogle. Is Chacharoon's dearerest wish."
--   2057  Chacharoon 17924231 msg 8117  the shorter nudge, reused from the
--                                        previous quest's closing line
--   2049  DIRECTOR 17924176   msgs 8194-8231  the turn-in, ending on Susuroon
--                                        admitting Chacharoon is his son
--
-- All three fired at the puppet and read back:
--   2058 -> "Please be paaassing spool of cotton thread to moogle."
--   2057 -> "Chief, tell moogle of Chacharoon's graaand feat!"
--   2049 -> "Maaany thanks! Chacharoon very joyful!" / "In return, Chacharoon
--           tasty-make slice of roast mutton from sheep." The client names the
--           reward item itself, which is why quest.reward carries exactly that.
--
-- The quest opens with no cutscene of its own: Feeding Frenzy's closing scene
-- already ends on 8192, the moogle offering to take the thread.
--
-- This is the quest that flips xi.monsterRearing.unlocked, which is what lets
-- Chacharoon's own script open the rearing options instead of turning the player
-- away.
-----------------------------------
require('scripts/globals/quests')
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CRY_NOT_CARETAKER)

quest.reward =
{
    item    = xi.item.SLICE_OF_ROAST_MUTTON,
    keyItem = xi.ki.LAMB_MEMENTO,
    title   = xi.title.SUBLIME_SLICER,
}

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
                    return quest:event(2058)
                end,
            },

            ['Green_Thumb_Moogle'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.SPOOL_OF_COTTON_THREAD) then
                        return quest:progressEvent(2049)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(2057)
                end,
            },

            onEventFinish =
            {
                [2049] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
