-----------------------------------
-- A Pioneer's Best (Imaginary) Friend
-----------------------------------
-- Log ID: 9, Quest ID: 75
-- Merleg !pos 34 0 -131 256
-- Ruth   !pos -144 4 -10 256
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.A_PIONEERS_BEST_IMAGINARY_FRIEND)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Merleg'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(2520)
                end,
            },

            onEventFinish =
            {
                [2520] = function(player, csid, option, npc)
                    quest:begin(player)

                    if player:hasStatusEffect(xi.effect.IONIS) then
                        player:startEvent(2522)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                player:getCurrentMission(xi.mission.log_id.SOA) >= xi.mission.id.soa.LIFE_ON_THE_FRONTIER
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Merleg'] =
            {
                onTrigger = function(player, npc)
                    if player:hasStatusEffect(xi.effect.IONIS) then
                        return quest:progressEvent(2522)
                    else
                        return quest:progressEvent(2521)
                    end
                end,
            },

            ['Ruth'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasStatusEffect(xi.effect.IONIS) then
                        return quest:progressEvent(2523)
                    end
                end,
            },

            onEventFinish =
            {
                [2522] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:addExp(500 * xi.settings.main.EXP_RATE)
                        npcUtil.giveCurrency(player, 'bayld', 200)
                        npcUtil.giveKeyItem(player, xi.ki.FAIL_BADGE)
                        player:addFame(xi.fameArea.ADOULIN, 30)
                    end
                end,

                [2523] = function(player, csid, option, npc)
                    player:delStatusEffectsByFlag(xi.effectFlag.INFLUENCE, true)
                    player:addStatusEffect(xi.effect.IONIS, 0, 0, 9000)
                end,
            },
        },
    },
}

return quest
