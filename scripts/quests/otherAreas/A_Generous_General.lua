-----------------------------------
-- A Generous General?
-----------------------------------
-- Log ID: 4, Quest ID: 109
-- Faulpie : Tanners' Guild, Southern San d'Oria
-----------------------------------
-- Retail: Leathercraft-gated Goblin disguise chain. Simplified for
-- 4-player server: accept + immediate complete. Craft + disguise
-- mechanics skipped.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_GENEROUS_GENERAL)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
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
                    return quest:progressEvent(720)
                end,
            },

            onEventFinish =
            {
                [720] = function(player, csid, option, npc)
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
