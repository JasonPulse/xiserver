-----------------------------------
-- Girl in the Looking Glass
-----------------------------------
-- Log ID: 3, Quest ID: 78
-- Luto_Mewrilah : Upper Jeuno (G-8), default event 10034
-- First step of the Adventuring Fellow bond-cap chain. Chain order:
-- Girl in the Looking Glass → Past Reflections → Blighted Gloom →
-- Blessed Radiance → Mirror Images. Simplified for 4-player server:
-- accept → immediate complete; unlocks Past Reflections.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.GIRL_IN_THE_LOOKING_GLASS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.UNLISTED_QUALITIES)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10037)
                end,
            },

            onEventFinish =
            {
                [10037] = function(player, csid, option, npc)
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
