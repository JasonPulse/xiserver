-----------------------------------
-- The Big One
-----------------------------------
-- Log ID: 4, Quest ID: 70
-- Travonce : Tavnazian Safehold (one of multiple entries; also at
-- Carpenters' Landing). Verified in npc_list.sql.
-----------------------------------
-- Retail: escort Travonce while he fishes at Port, defeat 3 Flesh-type
-- NMs. Simplified for 4-player server: accept → zone into Carpenters'
-- Landing → return to Travonce for reward.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.THE_BIG_ONE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.OTHER_AREAS,
    gil      = 3000,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Travonce'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(300)
                end,
            },

            onEventFinish =
            {
                [300] = function(player, csid, option, npc)
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

        [xi.zone.CARPENTERS_LANDING] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Visited') == 0 then
                    quest:setVar(player, 'Visited', 1)
                end

                return -1
            end,
        },

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Travonce'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Visited') == 1 then
                        return quest:progressEvent(301)
                    end
                end,
            },

            onEventFinish =
            {
                [301] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
