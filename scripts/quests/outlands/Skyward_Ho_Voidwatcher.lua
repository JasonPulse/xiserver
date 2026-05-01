-----------------------------------
-- Skyward Ho, Voidwatcher!
-----------------------------------
-- Log ID: 5, Quest ID: 104
-- Kieran : Norg (H-8) starts; Gilgamesh finishes
-----------------------------------
-- Voidwatch Op — retail targeted Aello / Qilin / Uptala Tier III NMs in
-- Tu'Lia region. VW not yet implemented; stub accepts + completes
-- immediately until VW Lite is built.
-----------------------------------
local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.SKYWARD_HO_VOIDWATCHER)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.NORG,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.OUTLANDS, xi.quest.id.outlands.VW_OP_115_LI_TELOR_VARIANT)
        end,

        [xi.zone.NORG] =
        {
            ['Kieran'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(304)
                end,
            },

            onEventFinish =
            {
                [304] = function(player, csid, option, npc)
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
