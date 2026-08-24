-----------------------------------
-- Coastal Chaos
-----------------------------------
-- Log ID: 4, Quest ID: 116
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 116
-----------------------------------
-- Retail (bg-wiki "Coastal Chaos").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Pond Probing  |Next=Seed Sowing
-- |Reward=Miscellaneous Fish and Rusty Items, Herb Seeds
--   1. "You will be told to pull up your Coastal Fishing Net on the beach. The net is
--      on the Southeast corner of your island."
--   2. "After pulling up the net, return to the moogle."
--   3. "After a cutscene, you will be given a bag of Herb Seeds and automatically
--      start the next quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, with one exception noted below:
--   2019 -> "It's detestable, deplorable, despicable even!" / "What was that? Poles
--           and perimeters aren't perfectly paired..." / "No matter, just nudge the
--           netting that's sitting near the sandy shore and come calling when you've
--           finished."                                    the standing instruction
--   2006 -> the turn-in. This is the ONE csid in the chain that could not be made to
--           render standalone. It is the crab-confrontation cutscene (msgs 7672
--           onward, "Kupooooooooo... I've descried thy deceptions and shall dutifully
--           deliver thy quietus"), so it needs actors that are not spawned for a bare
--           !cs, and it stayed silent with the quest in the log and with params 0 and
--           1. It is taken from POSITION inside a series that is otherwise verified:
--           2002, 2003, 2004, 2005, 2007 render the turn-ins of Full Fields, Green
--           Groves, Mining Missive, Pond Probing and Seed Sowing, in chain order, so
--           2006 is Coastal Chaos by elimination rather than by guess.
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.COASTAL_CHAOS)

quest.reward =
{
    item = xi.item.BAG_OF_HERB_SEEDS,
}

-- Records that the net was hauled in.
--
-- This deliberately returns nothing. The interaction framework only prioritises the
-- handler system when a handler produced an action (`#actions > 0`), so returning
-- nil lets the call fall through to the net's own script and hand over its yield as
-- normal. Setting the flag is idempotent, which matters because the framework
-- evaluates handlers while collecting candidate actions.
local gatherAction =
{
    onTrigger = function(player, npc)
        quest:setVar(player, 'Gathered', 1)
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.POND_PROBING) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2019)
                end,
            },

            onEventFinish =
            {
                [2019] = function(player, csid, option, npc)
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
            ['Coastal_Fishing_Net'] = gatherAction,

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Gathered') == 0 then
                        return quest:event(2019)
                    end

                    return quest:progressEvent(2006)
                end,
            },

            onEventFinish =
            {
                [2006] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Gathered', 0)
                    end
                end,
            },
        },
    },
}

return quest
