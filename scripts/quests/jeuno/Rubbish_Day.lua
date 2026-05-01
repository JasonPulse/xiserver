-----------------------------------
-- Rubbish Day
-----------------------------------
-- Log ID: 3, Quest ID: 13
-- Chululu !pos -13 -6 -42 245
-- Mashira !pos 141 -6 138 200 (Garlaige Citadel)
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.RUBBISH_DAY)

quest.reward =
{
    gil  = 6000,
    item = xi.item.CHAIN_CHOKER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.JEUNO, xi.quest.id.jeuno.COLLECT_TARUT_CARDS) == xi.questStatus.QUEST_COMPLETED and
                player:getCharVar('RubbishDay_day') ~= VanadielUniqueDay()
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(198)
                end,
            },

            onEventFinish =
            {
                [198] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.MAGIC_TRASH)
                        player:setCharVar('RubbishDay_prog', 0)
                        player:setCharVar('RubbishDay_day', VanadielUniqueDay())
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Chululu'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('RubbishDayVar') == 1 then
                        return quest:progressEvent(197)
                    else
                        return quest:progressEvent(49)
                    end
                end,
            },

            onEventFinish =
            {
                [197] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setCharVar('RubbishDayVar', 0)
                    end
                end,
            },
        },

        [xi.zone.GARLAIGE_CITADEL] =
        {
            ['Mashira'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('RubbishDayVar') == 0 then
                        return quest:progressEvent(11, 1)
                    end
                end,
            },

            onEventFinish =
            {
                [11] = function(player, csid, option, npc)
                    if option == 1 then
                        player:delKeyItem(xi.ki.MAGIC_TRASH)
                        player:setCharVar('RubbishDayVar', 1)
                    end
                end,
            },
        },
    },
}

return quest
