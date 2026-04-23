-----------------------------------
-- Records of Eminence
-----------------------------------
-- Log ID: 4, Quest ID: 110
-- Isakoth : Bastok Markets (E-11), A.M.A.N. rep (verified in npc_list.sql)
-----------------------------------
-- Retail: canonical ROE unlock (Memorandoll KI). The server's ROE system
-- already works, so this quest is flavor-only here — completing it
-- doesn't add functionality. Implemented for log progression.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.RECORDS_OF_EMINENCE)

quest.reward =
{
    fame     = 10,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Isakoth'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(800)
                end,
            },

            onEventFinish =
            {
                [800] = function(player, csid, option, npc)
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
