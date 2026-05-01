-----------------------------------
-- VW Op. 026: Tavnazian Terrors
-----------------------------------
-- Log ID: 4, Quest ID: 84
-- Owain : Tavnazian Safehold (verified in npc_list.sql)
-----------------------------------
-- Voidwatch Op quest — retail required VW infrastructure to spawn Fjalar
-- (Attohwa), Abununnu (Lufaise), Tsui-Goab (Misareaux). Voidwatch not
-- yet implemented on this server; stub accepts + immediately completes
-- until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.VW_OP_026_TAVNAZIAN_TERRORS)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Owain'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(600)
                end,
            },

            onEventFinish =
            {
                [600] = function(player, csid, option, npc)
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
