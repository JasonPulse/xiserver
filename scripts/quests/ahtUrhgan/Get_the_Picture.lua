-----------------------------------
-- Get the Picture
-----------------------------------
-- Log ID: 6, Quest ID: 4
-- Balakaf : Aht Urhgan Whitegate (I-5)
-----------------------------------
-- Retail: Image Recorder KI + 8 time/weather-gated photos across zones.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.GET_THE_PICTURE)

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

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Balakaf'] =
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
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
