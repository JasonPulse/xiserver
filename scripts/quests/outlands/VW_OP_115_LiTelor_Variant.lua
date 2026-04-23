-----------------------------------
-- VW Op. 115: Li'Telor Variant
-----------------------------------
-- Log ID: 5, Quest ID: 103
-- Kieran : Norg (post-Border Crossing)
-----------------------------------
-- Voidwatch Op — retail targeted Cath Palug / Modron / Mimic King Tier II
-- NMs in the Li'Telor region. VW not yet implemented; stub accepts +
-- completes immediately until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_115_LI_TELOR_VARIANT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.NORG,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_054_ELSHIMO_LIST) and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_101_DETOUR_TO_ZEPWELL)
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(303)
                end,
            },

            onEventFinish =
            {
                [303] = function(player, csid, option, npc)
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
