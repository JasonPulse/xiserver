-----------------------------------
-- A Potter's Preference
-----------------------------------
-- Log ID: 4, Quest ID: 9
-- Nereus (Mhaura)
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_POTTERS_PREFERENCE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 5
        end,

        [xi.zone.MHAURA] =
        {
            ['Nereus'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(111, xi.item.DISH_OF_GUSGEN_CLAY)
                end,
            },

            onEventFinish =
            {
                [111] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                (status == xi.questStatus.QUEST_COMPLETED and
                    (player:getCharVar('QuestAPotterPrefeCompDay_var') + 8 <= VanadielUniqueDay() or
                    quest:getVar(player, 'Repeat') == 1))
        end,

        [xi.zone.MHAURA] =
        {
            ['Nereus'] =
            {
                onTrigger = function(player, npc)
                    local status = player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_POTTERS_PREFERENCE)

                    if status == xi.questStatus.QUEST_ACCEPTED then
                        return quest:progressEvent(114, xi.item.DISH_OF_GUSGEN_CLAY)
                    elseif quest:getVar(player, 'Repeat') == 1 then
                        return quest:progressEvent(114, xi.item.DISH_OF_GUSGEN_CLAY)
                    else
                        return quest:progressEvent(112)
                    end
                end,

                onTrade = function(player, npc, trade)
                    local status = player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_POTTERS_PREFERENCE)
                    local canTurnIn = status == xi.questStatus.QUEST_ACCEPTED or quest:getVar(player, 'Repeat') == 1

                    if canTurnIn and npcUtil.tradeHas(trade, xi.item.DISH_OF_GUSGEN_CLAY) then
                        return quest:progressEvent(113)
                    end
                end,
            },

            onEventFinish =
            {
                [112] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:setVar(player, 'Repeat', 1)
                    end
                end,

                [113] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:addFame(xi.fameArea.WINDURST, 120)
                    npcUtil.giveCurrency(player, 'gil', 2160)
                    quest:setVar(player, 'Repeat', 0)
                    player:setCharVar('QuestAPotterPrefeCompDay_var', VanadielUniqueDay())

                    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.A_POTTERS_PREFERENCE) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
