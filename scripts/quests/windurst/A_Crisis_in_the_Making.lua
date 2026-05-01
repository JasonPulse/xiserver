-----------------------------------
-- A Crisis in the Making
-----------------------------------
-- Log ID: 2, Quest ID: 2
-- Ranpi-Monpi         !pos -116 -3 52  238
-- Altar of Offerings  !pos -137 17 177 145 (Giddeus)
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.A_CRISIS_IN_THE_MAKING)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2 and
                not player:needToZone()
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(258, 0, 625)
                end,
            },

            onEventFinish =
            {
                [258] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        player:setCharVar('QuestCrisisMaking_var', 1)
                    end

                    player:needToZone(true)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    local prog = player:getCharVar('QuestCrisisMaking_var')

                    if prog == 1 then
                        return quest:progressEvent(262, 0, 625)
                    elseif prog == 2 then
                        return quest:progressEvent(267)
                    end
                end,
            },

            onEventFinish =
            {
                [267] = function(player, csid, option, npc)
                    npcUtil.giveCurrency(player, 'gil', 400)
                    player:setCharVar('QuestCrisisMaking_var', 0)
                    player:delKeyItem(xi.ki.OFF_OFFERING)
                    player:addFame(xi.fameArea.WINDURST, 75)
                    quest:complete(player)
                    player:needToZone(true)
                end,
            },
        },

        [xi.zone.GIDDEUS] =
        {
            ['Altar_of_Offerings'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('QuestCrisisMaking_var') == 1 then
                        return quest:progressEvent(53)
                    end
                end,
            },

            onEventFinish =
            {
                [53] = function(player, csid, option, npc)
                    if option == 1 then
                        npcUtil.giveKeyItem(player, xi.ki.OFF_OFFERING)
                        player:setCharVar('QuestCrisisMaking_var', 2)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ranpi-Monpi'] =
            {
                onTrigger = function(player, npc)
                    local prog = player:getCharVar('QuestCrisisMaking_var')

                    if prog == 0 and not player:needToZone() then
                        return quest:progressEvent(259, 0, 625)
                    elseif prog == 1 then
                        return quest:progressEvent(262, 0, 625)
                    elseif prog == 2 then
                        return quest:progressEvent(268)
                    end
                end,
            },

            onEventFinish =
            {
                [259] = function(player, csid, option, npc)
                    if option == 1 then
                        player:setCharVar('QuestCrisisMaking_var', 1)
                    end

                    player:needToZone(true)
                end,

                [268] = function(player, csid, option, npc)
                    npcUtil.giveCurrency(player, 'gil', 400)
                    player:setCharVar('QuestCrisisMaking_var', 0)
                    player:delKeyItem(xi.ki.OFF_OFFERING)
                    player:addFame(xi.fameArea.WINDURST, 8)
                    player:needToZone(true)
                end,
            },
        },

        [xi.zone.GIDDEUS] =
        {
            ['Altar_of_Offerings'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('QuestCrisisMaking_var') == 1 then
                        return quest:progressEvent(53)
                    end
                end,
            },
        },
    },
}

return quest
