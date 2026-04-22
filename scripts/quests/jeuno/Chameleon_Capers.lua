-----------------------------------
-- Chameleon Capers
-----------------------------------
-- Log ID: 3, Quest ID: 84
-- Luto Mewrilah : Upper Jeuno (G-8), default event 10034
-- Retail: fellow familiarity 65+ costume kit child sidequest. Server
-- has no fellow API binding yet, so the familiarity gate is dropped.
-- Simplified for 4-player server: accept → immediate complete, random
-- Tactics Manual reward (Strategy / Discipline / Theory).
-----------------------------------
local tacticsManuals = { 5334, 5335, 5336 } -- Strategy, Discipline, Theory (numeric fallback)

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.CHAMELEON_CAPERS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10035)
                end,
            },

            onEventFinish =
            {
                [10035] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        if quest:complete(player) then
                            local reward = tacticsManuals[math.random(1, #tacticsManuals)]
                            player:addItem(reward)
                            player:messageSpecial(zones[xi.zone.UPPER_JEUNO].text.ITEM_OBTAINED, reward)
                        end
                    end
                end,
            },
        },
    },
}

return quest
