-----------------------------------
-- Forging a New Myth
-----------------------------------
-- Log ID: 6, Quest ID: 72
-- Nashmeira : Imperial Ward
-----------------------------------
-- Mythic chain #3. Retail: collect Tinnin's Fang + Sarameya's Hide +
-- Tyger's Tail, fight Zahak then Balrahn. Simplified for 4-player
-- server: accept + complete. Boss fights skipped.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.FORGING_A_NEW_MYTH)

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
                player:hasCompletedQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.DUTIES_TASKS_AND_DEEDS)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Nashmeira'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(220)
                end,
            },

            onEventFinish =
            {
                [220] = function(player, csid, option, npc)
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
