-----------------------------------
-- Totoroon's Treasure Hunt
-----------------------------------
-- Log ID: 6, Quest ID: 18
-- Totoroon : Nashmau (G-8)
-----------------------------------
-- Retail: trade fruit, harvest ??? box in assigned zone.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.TOTOROONS_TREASURE_HUNT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.NASHMAU] =
        {
            ['Totoroon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(130)
                end,
            },

            onEventFinish =
            {
                [130] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
