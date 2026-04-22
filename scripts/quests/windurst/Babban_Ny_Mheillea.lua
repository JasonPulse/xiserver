-----------------------------------
-- Babban Ny Mheillea
-----------------------------------
-- Log ID: 2, Quest ID: 95
-- Khoto Rokkorah : Windurst Waters (H-10), default event 988
-- Peculiar Rootprints : Rolanberry Fields [S] H-14, North Gustaberg [S] E-11,
--                        Meriphataud Mountains [S] L-4
-- Requires WotG access.
-----------------------------------
-- Retail: touch 3 Peculiar Rootprints across [S] zones in any order,
-- return to Khoto Rokkorah for 3 Tree Saplings + title.
-- Simplified for 4-player server: zoning into each of the 3 [S] zones
-- while the quest is active flags that zone as visited (bitmask).
-- When all 3 bits are set, Khoto Rokkorah finishes the quest. Skips
-- pinpoint rootprint position hunt.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local BAG_OF_TREE_SAPLINGS = xi.item.BAG_OF_TREE_SAPLINGS

local ROLANBERRY_BIT   = 1
local GUSTABERG_BIT    = 2
local MERIPHATAUD_BIT  = 4
local ALL_ROOTS_MASK   = 7

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.BABBAN_NY_MHEILLEA)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
    title    = xi.title.BABBANS_TRAVELING_COMPANION,
}

local function flagRoot(player, bit)
    local mask = quest:getVar(player, 'Roots')
    if not utils.mask.getBit(mask, bit - 1) then
        quest:setVar(player, 'Roots', utils.mask.setBit(mask, bit - 1, true))
    end
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(989)
                end,
            },

            onEventFinish =
            {
                [989] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ROLANBERRY_FIELDS_S] =
        {
            onZoneIn = function(player, prevZone)
                flagRoot(player, ROLANBERRY_BIT)
                return -1
            end,
        },

        [xi.zone.NORTH_GUSTABERG_S] =
        {
            onZoneIn = function(player, prevZone)
                flagRoot(player, GUSTABERG_BIT)
                return -1
            end,
        },

        [xi.zone.MERIPHATAUD_MOUNTAINS_S] =
        {
            onZoneIn = function(player, prevZone)
                flagRoot(player, MERIPHATAUD_BIT)
                return -1
            end,
        },

        [xi.zone.WINDURST_WATERS] =
        {
            ['Khoto_Rokkorah'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Roots') == ALL_ROOTS_MASK then
                        return quest:progressEvent(990)
                    end
                end,
            },

            onEventFinish =
            {
                [990] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        for _ = 1, 3 do
                            player:addItem(BAG_OF_TREE_SAPLINGS)
                        end
                    end
                end,
            },
        },
    },
}

return quest
