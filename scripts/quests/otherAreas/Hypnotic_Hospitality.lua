-----------------------------------
-- Hypnotic Hospitality
-----------------------------------
-- Log ID: 4, Quest ID: 121
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 121
-----------------------------------
-- Retail (bg-wiki "Hypnotic Hospitality").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other
-- |Previous=Trinket for the Tyrant  |Next=Titillating Tomes
-- |Title=Quartet Captivator  |Reward=Hoe
-- |Item Reqs=Gnatbane, Date, Moat Carp Creel
--   "After visiting your Mog Garden for 19 different Earth days, you will be cleared
--    on the 20th day for this quest. Having 20 stars on your GPS crystal might not
--    necessarily be enough as you can obtain extra stars during certain campaigns."
--   1. "Speak with the Green Thumb Moogle for a dialogue, initiating this quest."
--   2. "Obtain and trade your Green Thumb Moogle a Moat Carp Creel, a Date, and a
--      Gnatbane."
--   3. "Trade the three items to the Green Thumb Moogle and he will say to come back
--      in a day or so."
--   4. "Wait one game day and zone back into your Mog Garden. A cutscene will start
--      as you zone in."
--   5. "After the cutscene speak to your Green Thumb Moogle to complete the quest and
--      receive your Hoe."
--
-- The three items are named by the client itself, not just by bg-wiki: csid 2029
-- renders "we'll need you to pluck a creel of moat carp from the pond and filch both
-- a branch of gnatbane and a date from the furrows", and the event's data table
-- carries ids 5810, 5566 and 5984, which are exactly those three items.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, with one exception noted below:
--   2028 -> "So, so sleepy...and it's all caused by that correspondence course in
--           hypnotic hijinks, kupo." ... "Kupellion decided to drop by this Mog
--           Garden, kupo."                                              the offer
--   2029 -> "I can't wait for the wondrous and wild wassailing when we all meet!" /
--           "To kick off this commemorative carnival, we'll need you to pluck a creel
--           of moat carp from the pond and filch both a branch of gnatbane and a date
--           from the furrows, kupo."                                 the reminder
--   2030 -> "Thirty thousand thanks be to thee, kupo!" / "The troops are trekking
--           towards Adoulin as I articulate this very assertion. They should
--           disembark in a day or so, kupo."                      the trade turn-in
--   2031 -> "Entrust us with the excess exercises in expectancy. You've already laden
--           yourself with loads more than the lion's share, kupo."
--                                                       the reminder while waiting
--   2033 -> "What happened, kupo?" / "Did the hypnosis fail to fix Kupivolo's foul
--           frame of mind? Did he damage this domain and drive away our dear guests?"
--                                                     the post-party completion talk
--   2032 -> the party cutscene itself, and the ONE csid here that would not render
--           standalone. It is a multi-actor scene (Kupont, Kupivolo and Kupellion all
--           speak, msgs 7833 onward) and those actors are not spawned for a bare !cs.
--           It is taken from POSITION: 2028, 2029, 2030, 2031 and 2033 are all
--           verified and consecutive, and 2032 is the only gap, sitting exactly where
--           bg-wiki puts the zone-in cutscene.
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.HYPNOTIC_HOSPITALITY)

local visitDaysRequired = 20

quest.reward =
{
    item  = xi.item.HOE,
    title = xi.title.QUARTET_CAPTIVATOR,
}

local partySupplies =
{
    xi.item.CREEL_OF_MOAT_CARP,
    xi.item.DATE,
    xi.item.BRANCH_OF_GNATBANE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRINKET_FOR_THE_TYRANT) == xi.questStatus.QUEST_COMPLETED and
                xi.mog_garden.visitDays(player) >= visitDaysRequired
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2028)
                end,
            },

            onEventFinish =
            {
                [2028] = function(player, csid, option, npc)
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
            -- "Wait one game day and zone back into your Mog Garden." The day the
            -- supplies were handed over is stored, so the party fires on any entry
            -- after that Vana'diel day has rolled over.
            onZoneIn = function(player, prevZone)
                local handedOver = quest:getVar(player, 'SuppliesDay')

                if
                    handedOver == 0 or
                    quest:getVar(player, 'PartySeen') ~= 0 or
                    VanadielUniqueDay() <= handedOver
                then
                    return
                end

                quest:setVar(player, 'PartySeen', 1)

                return 2032
            end,

            ['Green_Thumb_Moogle'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'SuppliesDay') == 0 and
                        npcUtil.tradeHasExactly(trade, partySupplies)
                    then
                        return quest:progressEvent(2030)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'SuppliesDay') == 0 then
                        return quest:event(2029)
                    elseif quest:getVar(player, 'PartySeen') == 0 then
                        return quest:event(2031)
                    end

                    return quest:progressEvent(2033)
                end,
            },

            onEventFinish =
            {
                [2030] = function(player, csid, option, npc)
                    quest:setVar(player, 'SuppliesDay', VanadielUniqueDay())
                end,

                [2033] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'SuppliesDay', 0)
                        quest:setVar(player, 'PartySeen', 0)
                    end
                end,
            },
        },
    },
}

return quest
