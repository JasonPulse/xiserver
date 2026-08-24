-----------------------------------
-- Green Groves
-----------------------------------
-- Log ID: 4, Quest ID: 113
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 113
-----------------------------------
-- Retail (bg-wiki "Green Groves").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Full Fields  |Next=Mining Missive
-- |Reward=Miscellaneous Crystals and Logging Materials
--   1. "Immediately after the previous quest, the Green Thumb Moogle will tell you
--      to log from the nearby Arboreal Grove."
--   2. "Log from the grove, and report to the Moogle afterwards."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. csidmsg.py's positional attribution is WRONG
-- for this zone -- it puts msgs 7631/7632 on csid 2009, but firing 2009 in game
-- renders 7629/7630 instead. Every csid below was fired at the puppet and the text
-- it rendered was read back off the chat stream:
--   2016 -> "Examine the earth-rupturing roots to reveal riveting rewards!" /
--           "Well, maybe not 'riveting,' but rewards nonetheless, kupo."
--                                                    the standing instruction
--   2003 -> "Thank you for collecting those cursed comestibles." / "As an aside,
--           should you lack ligneous libations, logging will lay you up with
--           some arrowwood logs, kupo."                            the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.GREEN_GROVES)

-- Every node of a family shares one pool, and bg-wiki names the family rather than
-- a particular one, so any of them satisfies the step.
local groveNodes =
{
    'Arboreal_Grove',
    'Arboreal_Grove_#2',
    'Arboreal_Grove_#3',
    'Arboreal_Grove_#4',
}

-- Records that the step's gathering actually happened.
--
-- This deliberately returns nothing. The interaction framework only prioritises the
-- handler system when a handler produced an action (`#actions > 0`), so returning
-- nil lets the call fall through to the node's own script and hand over its yield
-- as normal. Setting the flag is idempotent, which matters because the framework
-- evaluates handlers while collecting candidate actions.
local gatherAction =
{
    onTrigger = function(player, npc)
        quest:setVar(player, 'Gathered', 1)
    end,
}

local acceptedZone =
{
    ['Green_Thumb_Moogle'] =
    {
        onTrigger = function(player, npc)
            if quest:getVar(player, 'Gathered') == 0 then
                return quest:event(2016)
            end

            return quest:progressEvent(2003)
        end,
    },

    onEventFinish =
    {
        [2003] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Gathered', 0)
            end
        end,
    },
}

for _, nodeName in ipairs(groveNodes) do
    acceptedZone[nodeName] = gatherAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FULL_FIELDS) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2016)
                end,
            },

            onEventFinish =
            {
                [2016] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MOG_GARDEN] = acceptedZone,
    },
}

return quest
