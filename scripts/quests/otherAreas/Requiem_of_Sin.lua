-----------------------------------
-- Requiem of Sin
-----------------------------------
-- Log ID: 4, Quest ID: 83
-- Despachiaire : Mhaura (verified in npc_list.sql)
-----------------------------------
-- Retail: post-COP, Letter from Shikaree Y → Boneyard Gully BCNM vs
-- Shikarees. Simplified for 4-player server: Despachiaire accepts +
-- completes. BCNM and random Armoury Crate rewards dropped.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.REQUIEM_OF_SIN)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.MHAURA] =
        {
            ['Despachiaire'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(500)
                end,
            },

            onEventFinish =
            {
                [500] = function(player, csid, option, npc)
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
