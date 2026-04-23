-----------------------------------
-- VW Op. 004: Bibiki Bombardment
-----------------------------------
-- Log ID: 4, Quest ID: 85
-- Owain : Tavnazian Safehold (verified in npc_list.sql)
-----------------------------------
-- Voidwatch Op quest — retail required VW infrastructure to spawn
-- Bismarck in Bibiki Bay. Voidwatch not yet implemented on this server;
-- stub accepts + immediately completes until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_004_BIBIKI_BOMBARDMENT)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.OTHER_AREAS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_026_TAVNAZIAN_TERRORS)
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Owain'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(601)
                end,
            },

            onEventFinish =
            {
                [601] = function(player, csid, option, npc)
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
