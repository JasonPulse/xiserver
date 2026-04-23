-----------------------------------
-- Unity Concord
-----------------------------------
-- Log ID: 4, Quest ID: 111
-- Isakoth : Bastok Markets (E-11), A.M.A.N. rep (verified in npc_list.sql)
-----------------------------------
-- Retail: canonical Unity Concord unlock after 5 ROE objectives. The
-- server already forces unity rank 1 for warps (packet 0x061 fix), so
-- this quest is flavor-only here. Implemented for log progression.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.UNITY_CONCORD)

quest.reward =
{
    fame     = 10,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.RECORDS_OF_EMINENCE)
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Isakoth'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(801)
                end,
            },

            onEventFinish =
            {
                [801] = function(player, csid, option, npc)
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
