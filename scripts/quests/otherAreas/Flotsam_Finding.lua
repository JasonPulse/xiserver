-----------------------------------
-- Flotsam Finding
-----------------------------------
-- Log ID: 4, Quest ID: 118
-- Green Thumb Moogle : Mog Garden, entity 17924125
-- !addquest 4 118
-----------------------------------
-- Retail (bg-wiki "Flotsam Finding").
-- |Start=Green Thumb Moogle, Mog Garden  |Fame=Other  |Repeatable=No
-- |Previous=Seed Sowing  |Next=Courtesy Crustacean  |Title=Mog Garden Seedling
-- |Reward=Water Cluster, Garden Worm, Grove Worm, Stone Serum, Sardine Sphere,
--         Sardine Chum
--   1. "The Green Thumb Moogle instructs you to examine the sparkling Flotsam on the
--      beach."
--   2. "Examine the spot, and report back to the Moogle to complete the quest line."
--   "Random Items can be obtained from the Flotsam ... but the first time is just a
--    Water Cluster." That first-time guarantee is why the reward below is fixed; the
--    random table belongs to the Flotsam node itself, not to the quest.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, with one exception noted below:
--   2021 -> "Wonders from worlds beyond are wont to wash up on these shores." /
--           "Could you be so kind as to creep up to the coast and catch a glimpse of
--           what drifted down here?"                       the standing instruction
--   2008 -> the turn-in. Like Coastal Chaos's 2006 this one would not render
--           standalone. Its text (7694, "look what the whitewater whisked in, kupo. A
--           bona fide <item>") carries an item parameter, and it stayed silent both
--           bare and with the Water Cluster id passed as the first param, so the
--           parameter slot could not be determined from outside. It is taken from
--           POSITION in the otherwise verified 2002-2008 turn-in series, which maps
--           one-to-one onto the seven chain steps in order.
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FLOTSAM_FINDING)

quest.reward =
{
    item  = xi.item.WATER_CLUSTER,
    title = xi.title.MOG_GARDEN_SEEDLING,
}

-- Records that the flotsam was examined.
--
-- This deliberately returns nothing so the call falls through to the Flotsam node's
-- own script, which is what rolls and hands over the drift. See Full_Fields.lua for
-- why a nil return is the correct way to do that.
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
                player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.SEED_SOWING) == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.MOG_GARDEN] =
        {
            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2021)
                end,
            },

            onEventFinish =
            {
                [2021] = function(player, csid, option, npc)
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
            ['Flotsam'] = gatherAction,

            ['Green_Thumb_Moogle'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Gathered') == 0 then
                        return quest:event(2021)
                    end

                    return quest:progressEvent(2008)
                end,
            },

            onEventFinish =
            {
                [2008] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Gathered', 0)
                    end
                end,
            },
        },
    },
}

return quest
