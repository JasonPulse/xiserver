-----------------------------------
-- Regaining Trust
-----------------------------------
-- Log ID: 3, Quest ID: 85
-- Luto_Mewrilah : Upper Jeuno (G-8)
-- Monberaux : Upper Jeuno (in npc_list.sql) — has no dedicated script,
-- IF handler attaches by name.
-- Retail raised fellow lvlcap to 60 — dropped (no fellow API binding).
-- Quest still completes for log progression.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.REGAINING_TRUST)

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
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.PICTURE_PERFECT)
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10058)
                end,
            },

            onEventFinish =
            {
                [10058] = function(player, csid, option, npc)
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
