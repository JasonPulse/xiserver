-----------------------------------
-- Synergistic Support
-----------------------------------
-- Log ID: 1, Quest ID: 91
-- Hildolf : Metalworks (F-8)
-- Trade Slime Oil → pick Fewell element → receive 3 Fewell.
-- Item IDs: fire=2784, ice=2785, wind=2786, earth=2787, lightning=2788,
--   water=2789, light=2790, dark=2791 (contiguous from orb_of_fire_fewell).
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local FEWELL_FIRE      = 2784
local FEWELL_ICE       = 2785
local FEWELL_WIND      = 2786
local FEWELL_EARTH     = 2787
local FEWELL_LIGHTNING = 2788
local FEWELL_WATER     = 2789
local FEWELL_LIGHT     = 2790
local FEWELL_DARK      = 2791

local fewellByOption =
{
    [0] = FEWELL_FIRE,
    [1] = FEWELL_ICE,
    [2] = FEWELL_WIND,
    [3] = FEWELL_EARTH,
    [4] = FEWELL_LIGHTNING,
    [5] = FEWELL_WATER,
    [6] = FEWELL_LIGHT,
    [7] = FEWELL_DARK,
}

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGISTIC_SUPPORT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.VIAL_OF_SLIME_OIL) then
                        return quest:progressEvent(702)
                    end
                end,

                onTrigger = function(player, npc)
                    return quest:event(703)
                end,
            },

            onEventFinish =
            {
                [702] = function(player, csid, option, npc)
                    -- option encodes chosen element index 0-7
                    local fewellId = fewellByOption[option]
                    if fewellId == nil then
                        return
                    end
                    if player:getFreeSlotsCount() > 0 then
                        player:confirmTrade()
                        for _ = 1, 3 do
                            player:addItem(fewellId)
                        end
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
