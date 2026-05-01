-----------------------------------
-- VW Op. 068: Subterranean Skirmish
-----------------------------------
-- Log ID: 6, Quest ID: 69
-- Camille : Wajaom Woodlands (M-7)
-----------------------------------
-- Voidwatch Op stub — VW not yet implemented on this server. Accepts +
-- completes immediately until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.VW_OP_068_SUBTERRAINEAN_SKIRMISH)

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

        [xi.zone.WAJAOM_WOODLANDS] =
        {
            ['Camille'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(181)
                end,
            },

            onEventFinish =
            {
                [181] = function(player, csid, option, npc)
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
