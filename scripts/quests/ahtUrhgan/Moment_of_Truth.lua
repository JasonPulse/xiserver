-----------------------------------
-- Moment of Truth
-----------------------------------
-- Log ID: 6, Quest ID: 30
-- Mishhar : Aht Urhgan Whitegate (H-8)
-----------------------------------
-- Retail: Jade Sepulcher BCNM defending Minfram vs Mamool Ja.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.MOMENT_OF_TRUTH)

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
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.GIVE_PEACE_A_CHANCE)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Mishhar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(140)
                end,
            },

            onEventFinish =
            {
                [140] = function(player, csid, option, npc)
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
