-----------------------------------
-- The Art of War
-----------------------------------
-- Log ID: 6, Quest ID: 10
-- Hishahma : Aht Urhgan Whitegate (K-8)
-----------------------------------
-- Retail: follow-up to Finding Faults, defeat 3 NMs in beastman zones.
-- Simplified for 4-player server: accept + immediate complete.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.THE_ART_OF_WAR)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FINDING_FAULTS)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Hishahma'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(120)
                end,
            },

            onEventFinish =
            {
                [120] = function(player, csid, option, npc)
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
