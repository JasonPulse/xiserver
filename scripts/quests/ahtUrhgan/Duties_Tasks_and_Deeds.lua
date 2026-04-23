-----------------------------------
-- Duties, Tasks, and Deeds
-----------------------------------
-- Log ID: 6, Quest ID: 71
-- Paparoon : Nashmau (G-7)
-----------------------------------
-- Mythic chain #2. Retail: 30k Alexandrite or Cat's Eye + 150k Nyzul
-- tokens + all-50 Assault re-completion. Simplified for 4-player
-- server: accept + complete. Skips currency/token gates.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.DUTIES_TASKS_AND_DEEDS)

quest.reward =
{
    fame     = 60,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.AN_IMPERIAL_HEIST)
        end,

        [xi.zone.NASHMAU] =
        {
            ['Paparoon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(210)
                end,
            },

            onEventFinish =
            {
                [210] = function(player, csid, option, npc)
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
