-----------------------------------
-- The Search for Goldmane
-----------------------------------
-- Log ID: 5, Quest ID: 200
-- Zoriboh : Rabao (F-6)
-----------------------------------
-- Retail: Care Package KI → farm Copper Key from Riverne Vulture → trade
-- to Trunk. Simplified for 4-player server: accept → zone into
-- Riverne - Site A01 → return to Zoriboh for reward.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.THE_SEARCH_FOR_GOLDMANE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SELBINA_RABAO,
    gil      = 3000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(400)
                end,
            },

            onEventFinish =
            {
                [400] = function(player, csid, option, npc)
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

        [xi.zone.RIVERNE_SITE_A01] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Visited') == 0 then
                    quest:setVar(player, 'Visited', 1)
                end

                return -1
            end,
        },

        [xi.zone.RABAO] =
        {
            ['Zoriboh'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Visited') == 1 then
                        return quest:progressEvent(401)
                    end
                end,
            },

            onEventFinish =
            {
                [401] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
