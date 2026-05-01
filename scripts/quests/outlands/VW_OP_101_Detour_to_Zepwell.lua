-----------------------------------
-- VW Op. 101: Detour to Zepwell
-----------------------------------
-- Log ID: 5, Quest ID: 102
-- Gushing_Spring : Rabao (G-8)
-----------------------------------
-- Voidwatch Op — retail targeted Sabotender Campeador / Malleator Maurok /
-- Tangaroa Tier I NMs across Zepwell Island. VW not yet implemented;
-- stub accepts + completes immediately until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_101_DETOUR_TO_ZEPWELL)

quest.reward =
{
    fame     = 20,
    fameArea = xi.fameArea.SELBINA_RABAO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VOIDWATCH_OPS_BORDER_CROSSING)
        end,

        [xi.zone.RABAO] =
        {
            ['Gushing_Spring'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(302)
                end,
            },

            onEventFinish =
            {
                [302] = function(player, csid, option, npc)
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
