-----------------------------------
-- An Understanding Overlord?
-----------------------------------
-- Log ID: 4, Quest ID: 106
-- Faulpie : Tanners' Guild, Southern San d'Oria
-----------------------------------
-- Retail: Leathercraft-gated Orc disguise chain. Simplified for
-- 4-player server: accept + immediate complete. Craft + disguise
-- mechanics skipped.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.AN_UNDERSTANDING_OVERLORD)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.SOUTHERN_SAN_DORIA] =
        {
            ['Faulpie'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(700)
                end,
            },

            onEventFinish =
            {
                [700] = function(player, csid, option, npc)
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
