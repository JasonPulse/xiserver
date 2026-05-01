-----------------------------------
-- Unlisted Qualities
-----------------------------------
-- Log ID: 3, Quest ID: 77
-- Luto_Mewrilah : Upper Jeuno (G-8), default event 10034
-- NPC name verified against npc_list.sql.
-- Retail: choose fellow's appearance. Simplified for 4-player server:
-- accept → immediate complete → Silver Ingot reward.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.UNLISTED_QUALITIES)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
    item     = xi.item.SILVER_INGOT,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Luto_Mewrilah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10036)
                end,
            },

            onEventFinish =
            {
                [10036] = function(player, csid, option, npc)
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
