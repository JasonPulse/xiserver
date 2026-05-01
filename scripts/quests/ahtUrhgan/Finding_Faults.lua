-----------------------------------
-- Finding Faults
-----------------------------------
-- Log ID: 6, Quest ID: 8
-- Hishahma : Aht Urhgan Whitegate (K-8)
-----------------------------------
-- Retail: investigate ???s in Caedarva/Zhayolm/Wajaom, kill 3 NMs.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FINDING_FAULTS)

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
            ['Hishahma'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(110)
                end,
            },

            onEventFinish =
            {
                [110] = function(player, csid, option, npc)
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
