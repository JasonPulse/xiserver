-----------------------------------
-- Full Fields
-----------------------------------
-- Log ID: 4, Quest ID: 112
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 112
-----------------------------------
-- Retail (bg-wiki "Full Fields").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=None  |Next=Green Groves
-- |Reward=Miscellaneous Crystals and Gardening Materials
--   1. "Upon zoning in, your Green Thumb Moogle will give you a GPS crystal, and
--      instruct you to harvest from the nearby Garden Furrow."
--   2. "After harvesting from the Garden Furrow, report back to the Green Thumb
--      Moogle for your reward."
--   "You will automatically start the next quest after completing this one."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT. csidmsg.py's positional attribution is WRONG
-- for this zone -- it puts msgs 7631/7632 on csid 2009, but firing 2009 in game
-- renders 7629/7630 instead. Every csid below was fired at the puppet and the text
-- it rendered was read back off the chat stream:
--   2009 -> "Back in your Mog House, I bet gardening was a chore." / "Simply
--           stick your snout in that basket over there, and declare your
--           discoveries to me."                        the standing instruction
--   2002 -> "Congratulations on hauling in your headmost harvest!" / "Don't
--           forget, all that palatable produce and paraphernalia is yours for
--           the picking, kupo."                                   the turn-in
--
-- ONE MISMATCH WITH OUR GARDEN, worth knowing before this reads as broken. Retail's
-- step 1 is "peek inside the basket that rests at the end of the furrow", a free
-- starter harvest. Our Garden_Furrow has no starter basket: xi.mog_garden
-- .furrowOnTrigger only yields once a seed has been planted and has ripened, so an
-- untouched plot answers "The plot is empty." The quest still advances on the
-- examine, which keeps the chain completable and matches the retail flow, but the
-- crystals and gardening materials bg-wiki lists as the reward come from the furrow
-- and so are not handed over. That is a gap in the garden system, not in this quest,
-- and it closes by itself the day the furrow models the starter basket.
--
-- The retail opening cutscene is not reproduced. It is held on the hidden
-- DIRECTOR entity (17924176, status 6) and carries msgs 7624-7630; fired at the
-- puppet it renders nothing, so the quest opens on the GPS crystal grant and the
-- verified 2009 instruction rather than on a cutscene that could not be proven.
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FULL_FIELDS)

-- Every node of a family shares one pool, and bg-wiki names the family rather than
-- a particular one, so any of them satisfies the step.
local furrowNodes =
{
    'Garden_Furrow',
    'Garden_Furrow_#2',
    'Garden_Furrow_#3',
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
                return quest:event(2009)
            end

            return quest:progressEvent(2002)
        end,
    },

    onEventFinish =
    {
        [2002] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Gathered', 0)
            end
        end,
    },
}

for _, nodeName in ipairs(furrowNodes) do
    acceptedZone[nodeName] = gatherAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2009)
                end,
            },

            onEventFinish =
            {
                [2009] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.GPS_CRYSTAL)
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
