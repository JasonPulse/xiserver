-----------------------------------
-- Pond Probing
-----------------------------------
-- Log ID: 4, Quest ID: 115
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 115
-----------------------------------
-- Retail (bg-wiki "Pond Probing").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Mining Missive  |Next=Coastal Chaos
-- |Reward=Miscellaneous Fish and Rusty Items
--   1. "The Green Thumb Moogle instructs you to pull up the net in the nearby Pond
--      Dredger."
--   2. "After pulling up the net, return to the moogle."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. csidmsg.py's positional attribution is WRONG
-- for this zone -- it puts msgs 7631/7632 on csid 2009, but firing 2009 in game
-- renders 7629/7630 instead. Every csid below was fired at the puppet and the text
-- it rendered was read back off the chat stream:
--   2018 -> "Nurse the netting out of the swelling spring to see if that evil
--           entity got entangled in it." / "Should you find fishy fragments--or
--           anything at all--apprise me as soon as you're able, kupo."
--                                                    the standing instruction
--   2005 -> "Power to the pioneers, kupo! You've successfully seized the catch
--           of the day!" / "...Or not? I never knew the numbers of fish were so
--           negligible here."                                      the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.POND_PROBING)

-- Every node of a family shares one pool, and bg-wiki names the family rather than
-- a particular one, so any of them satisfies the step.
local pondNodes =
{
    'Pond_Dredger',
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
                return quest:event(2018)
            end

            return quest:progressEvent(2005)
        end,
    },

    onEventFinish =
    {
        [2005] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Gathered', 0)
            end
        end,
    },
}

for _, nodeName in ipairs(pondNodes) do
    acceptedZone[nodeName] = gatherAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MINING_MISSIVE) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2018)
                end,
            },

            onEventFinish =
            {
                [2018] = function(player, csid, option, npc)
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
