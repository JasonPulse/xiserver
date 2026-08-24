-----------------------------------
-- Seed Sowing
-----------------------------------
-- Log ID: 4, Quest ID: 117
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 117
-----------------------------------
-- Retail (bg-wiki "Seed Sowing").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Coastal Chaos  |Next=Flotsam Finding
--   1. "Plant your Herb Seeds in the Garden Furrow by trading them."
--   2. "Report your success to the Green Thumb Moogle."
--   3. "You will complete this quest after the cutscene, and automatically begin the
--      next."
--
-- This is the one step in the chain driven by a TRADE rather than an examine, which
-- is why the furrow hook below is onTrade.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT:
--   2020 -> "Eleven energetic exclamations! The enemy has been eliminated, kupo!" /
--           "Plant the precious seed I presented you and proclaim your progress to me
--           when you're finished, kupo."                  the standing instruction
--   2007 -> "I hope you enjoyed sowing your first seed. In honor of your
--           accomplishment, I shall now show you the dance of my people, kupo."
--                                                                       the turn-in
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.SEED_SOWING)

local furrowNodes =
{
    'Garden_Furrow',
    'Garden_Furrow_#2',
    'Garden_Furrow_#3',
}

-- bg-wiki names Herb Seeds specifically, because that is what Coastal Chaos hands
-- over, but the furrow accepts any seed bag and retail counts the sowing either way.
local seedBags =
{
    [xi.item.BAG_OF_VEGETABLE_SEEDS] = true,
    [xi.item.BAG_OF_FRUIT_SEEDS]     = true,
    [xi.item.BAG_OF_GRAIN_SEEDS]     = true,
    [xi.item.BAG_OF_HERB_SEEDS]      = true,
    [xi.item.BAG_OF_WILDGRASS_SEEDS] = true,
    [xi.item.BAG_OF_FLOWER_SEEDS]    = true,
}

-- Records that a seed was sown.
--
-- This deliberately returns nothing, and in particular does NOT call confirmTrade.
-- The interaction framework only prioritises the handler system when a handler
-- produced an action, so returning nil lets the trade fall through to
-- xi.mog_garden.furrowOnTrade, which is what actually plants the seed and consumes
-- it. Claiming the trade here would plant nothing.
local sowAction =
{
    onTrade = function(player, npc, trade)
        if seedBags[trade:getItemId()] then
            quest:setVar(player, 'Sown', 1)
        end
    end,
}

local acceptedZone =
{
    ['Green_Thumb_Moogle'] =
    {
        onTrigger = function(player, npc)
            if quest:getVar(player, 'Sown') == 0 then
                return quest:event(2020)
            end

            return quest:progressEvent(2007)
        end,
    },

    onEventFinish =
    {
        [2007] = function(player, csid, option, npc)
            if quest:complete(player) then
                quest:setVar(player, 'Sown', 0)
            end
        end,
    },
}

for _, nodeName in ipairs(furrowNodes) do
    acceptedZone[nodeName] = sowAction
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.COASTAL_CHAOS) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2020)
                end,
            },

            onEventFinish =
            {
                [2020] = function(player, csid, option, npc)
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
