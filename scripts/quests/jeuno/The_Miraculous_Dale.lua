-----------------------------------
-- The Miraculous Dale
-----------------------------------
-- Log ID: 3, Quest ID: 100
-- Rakuru-Rakoru : Lower Jeuno, default event 10078
-----------------------------------
-- Retail: defeat monsters for Data Analyzer/Logger EX.
-- Simplified for 4-player server: accept → zone out and back (simulated
-- "field work") → return to Rakuru-Rakoru for 59,630 gil.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_MIRACULOUS_DALE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
    gil      = 59630,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 75
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Rakuru-Rakoru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10079)
                end,
            },

            onEventFinish =
            {
                [10079] = function(player, csid, option, npc)
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
