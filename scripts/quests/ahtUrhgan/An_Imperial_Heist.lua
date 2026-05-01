-----------------------------------
-- An Imperial Heist
-----------------------------------
-- Log ID: 6, Quest ID: 70
-- Naja_Salaheem : Aht Urhgan Whitegate (I-10)
-----------------------------------
-- Mythic chain #1. Retail: ToAU M48 done + Runic Key KI + beastman
-- king gauntlet + Odin fight. Simplified for 4-player server: accept
-- from Naja → complete. Unlocks Duties, Tasks, and Deeds.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AN_IMPERIAL_HEIST)

quest.reward =
{
    fame     = 60,
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
            ['Naja_Salaheem'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(200)
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
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
