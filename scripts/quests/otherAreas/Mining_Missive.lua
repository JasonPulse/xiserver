-----------------------------------
-- Mining Missive
-----------------------------------
-- Log ID: 4, Quest ID: 114
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 114
-----------------------------------
-- Retail (bg-wiki "Mining Missive").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Green Groves  |Next=Pond Probing
-- |Reward=Miscellaneous Crystals and Mining Materials
--   1. "The Green Thumb Moogle instructs you to mine from the nearby Mineral Vein."
--   2. "After mining, return to the moogle to move on to the next quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. csidmsg.py's positional attribution is WRONG
-- for this zone -- it puts msgs 7631/7632 on csid 2009, but firing 2009 in game
-- renders 7629/7630 instead. Every csid below was fired at the puppet and the text
-- it rendered was read back off the chat stream:
--   2017 -> "A rotten reprobate's been running around like a rogue in the Mog
--           Garden, kupo." / "To stop this sorry sod, we'll need a pebble from
--           that bulky boulder beyond."             the standing instruction
--   2004 -> "Hip, hip, hooray, kupo!" / "With this pebble, we can smother,
--           smash, and smear that smug stowaway into oblivion!"    the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.MINING_MISSIVE)

-- Every node of a family shares one pool, and bg-wiki names the family rather than
-- a particular one, so any of them satisfies the step.
local veinNodes =
{
    'Mineral_Vein',
    'Mineral_Vein_#2',
    'Mineral_Vein_#3',
    'Mineral_Vein_#4',
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
                return quest:event(2017)
            end

            return quest:progressEvent(2004)
        end,
    },

    onEventFinish =
    {
        [2004] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Gathered', 0)
            end
        end,
    },
}

for _, nodeName in ipairs(veinNodes) do
    acceptedZone[nodeName] = gatherAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.GREEN_GROVES) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2017)
                end,
            },

            onEventFinish =
            {
                [2017] = function(player, csid, option, npc)
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
