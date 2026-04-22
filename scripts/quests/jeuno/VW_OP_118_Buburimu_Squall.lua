-----------------------------------
-- VW Op. 118: Buburimu Squall
-----------------------------------
-- Log ID: 3, Quest ID: 169
-- Mawlgofaur : Ru'Lude Gardens (verified in npc_list.sql)
-- Voidwatch Op quest — retail required VW infrastructure to spawn NM
-- Botulus Rex in Buburimu Peninsula. Voidwatch is not yet implemented;
-- stub accepts and immediately completes until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.VW_OP_118_BUBURIMU_SQUALL)

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
                    return quest:progressEvent(10055)
                end,
            },

            onEventFinish =
            {
                [10055] = function(player, csid, option, npc)
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
