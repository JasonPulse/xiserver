-----------------------------------
-- Promotion: Captain
-----------------------------------
-- Log ID: 6, Quest ID: 99
-- Abquhbah : Aht Urhgan Whitegate (I-10)
-----------------------------------
-- Retail: gated on all 50 Assaults + TOAU Mission 48 + First Lieutenant
-- rank. Simplified for 4-player server: accept + complete. Assault count
-- requirement dropped — 38 of 50 assault scenarios aren't implemented
-- anyway (see ASSAULT_LOOT_AUDIT.md).
-----------------------------------
local quest = Quest:new(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PROMOTION_CAPTAIN)

quest.reward =
{
    fame     = 80,
    fameArea = xi.fameArea.WINDURST,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedMission(xi.mission.log_id.TOAU, xi.mission.id.toau.PUPPET_IN_PERIL)
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Abquhbah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(400)
                end,
            },

            onEventFinish =
            {
                [400] = function(player, csid, option, npc)
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
