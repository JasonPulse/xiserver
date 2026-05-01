-----------------------------------
-- The Fireblom Tree
-----------------------------------
-- Log ID: 5, Quest ID: 1
-- Soun_Abralah : Kazham (H-9)
-----------------------------------
-- Retail: gather 4 vine KIs from Firebloom Tree Roots in Yuhtunga, fire-test
-- in Ifrit's Cauldron, return to matching root. Simplified for 4-player
-- server: accept → zone-in Yuhtunga Jungle + Ifrit's Cauldron sets flags →
-- return to Soun_Abralah for reward.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_FIREBLOOM_TREE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
    gil      = 5000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 6
        end,

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(100)
                end,
            },

            onEventFinish =
            {
                [100] = function(player, csid, option, npc)
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

        [xi.zone.YUHTUNGA_JUNGLE] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Gathered') == 0 then
                    quest:setVar(player, 'Gathered', 1)
                end

                return -1
            end,
        },

        [xi.zone.IFRITS_CAULDRON] =
        {
            onZoneIn = function(player, prevZone)
                if
                    quest:getVar(player, 'Gathered') == 1 and
                    quest:getVar(player, 'Tested') == 0
                then
                    quest:setVar(player, 'Tested', 1)
                end

                return -1
            end,
        },

        [xi.zone.KAZHAM] =
        {
            ['Soun_Abralah'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Tested') == 1 then
                        return quest:progressEvent(101)
                    end
                end,
            },

            onEventFinish =
            {
                [101] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
