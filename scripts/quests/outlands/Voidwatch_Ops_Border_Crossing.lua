-----------------------------------
-- Voidwatch Ops: Border Crossing
-----------------------------------
-- Log ID: 5, Quest ID: 100
-- Kieran : Norg (I-8)
-----------------------------------
-- Voidwatch Op hub quest — retail awarded Ashen Stratum Abyssite.
-- Voidwatch not yet implemented on this server; stub accepts +
-- immediately completes until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.NORG,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 75
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(300)
                end,
            },

            onEventFinish =
            {
                [300] = function(player, csid, option, npc)
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
