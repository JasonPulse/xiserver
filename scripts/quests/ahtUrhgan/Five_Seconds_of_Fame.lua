-----------------------------------
-- Five Seconds of Fame
-----------------------------------
-- Log ID: 6, Quest ID: 32
-- Balakaf : Aht Urhgan Whitegate (I-5)
-----------------------------------
-- Retail: photograph 5 timed Whitegate events.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FIVE_SECONDS_OF_FAME)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.GET_THE_PICTURE)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Balakaf'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(150)
                end,
            },

            onEventFinish =
            {
                [150] = function(player, csid, option, npc)
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
