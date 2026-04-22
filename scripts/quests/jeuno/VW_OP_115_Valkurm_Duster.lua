-----------------------------------
-- VW Op. 115: Valkurm Duster
-----------------------------------
-- Log ID: 3, Quest ID: 168
-- Mawlgofaur : Ru'Lude Gardens (verified in npc_list.sql as Mawlgofaur,
-- display name "Mawl'gofaur")
-- Voidwatch Op quest — retail required the full VW infrastructure to
-- spawn NM Ig-Alima in Valkurm Dunes. Voidwatch is not yet implemented
-- on this server (see VOIDWATCH_TODO.md). Stub: accept + immediate
-- complete; revisit once VW Lite is built so the quest gates on an
-- actual Ig-Alima kill.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.VW_OP_115_VALKURM_DUSTER)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.JEUNO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['Mawlgofaur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10054)
                end,
            },

            onEventFinish =
            {
                [10054] = function(player, csid, option, npc)
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
