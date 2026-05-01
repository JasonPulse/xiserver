-----------------------------------
-- The Rider Cometh
-----------------------------------
-- Log ID: 6, Quest ID: 76
-- Nashmeira : Imperial Ward, Aht Urhgan Whitegate
-----------------------------------
-- Odin arc quest. Retail: Timeworn Talisman + food trade, fight Odin
-- Prime in Hazhalm Testing Grounds. Simplified for 4-player server:
-- accept + complete. Odin fight and Pact/Aesir gear reward dropped —
-- revisit when Odin BCNM is implemented.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.THE_RIDER_COMETH)

quest.reward =
{
    fame     = 50,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Nashmeira'] =
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
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
