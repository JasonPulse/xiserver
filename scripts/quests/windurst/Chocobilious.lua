-----------------------------------
-- Chocobilious
-----------------------------------
-- Log ID: 2, Quest ID: 27
-- Kuoh Rhel     !pos 131.437 -6 -102.723 241
-- Tapoh Lihzeh  !pos 51.011 -3.749 54.402 241
-- Matata        !pos 131 -5 -109 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.CHOCOBILIOUS)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 220,
    gil      = 1500,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kuoh_Rhel'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(224)
                end,
            },

            onEventFinish =
            {
                [224] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kuoh_Rhel'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('ChocobiliousQuest') == 2 then
                        return quest:progressEvent(231)
                    else
                        return quest:progressEvent(225)
                    end
                end,
            },

            ['Tapoh_Lihzeh'] =
            {
                onTrigger = function(player, npc)
                    local prog = player:getCharVar('ChocobiliousQuest')

                    if prog == 2 then
                        return quest:progressEvent(230)
                    elseif prog == 1 then
                        return quest:progressEvent(228, 0, xi.item.PAPAKA_GRASS)
                    else
                        return quest:progressEvent(227, 0, xi.item.PAPAKA_GRASS)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        player:getCharVar('ChocobiliousQuest') == 1 and
                        npcUtil.tradeHas(trade, xi.item.PAPAKA_GRASS)
                    then
                        return quest:progressEvent(229, 0, xi.item.PAPAKA_GRASS)
                    end
                end,
            },

            onEventFinish =
            {
                [227] = function(player, csid, option, npc)
                    player:setCharVar('ChocobiliousQuest', 1)
                end,

                [229] = function(player, csid, option, npc)
                    player:setCharVar('ChocobiliousQuest', 2)
                end,

                [231] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:needToZone(true)
                        player:setCharVar('ChocobiliousQuest', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Kuoh_Rhel'] =
            {
                onTrigger = function(player, npc)
                    if player:needToZone() then
                        return quest:progressEvent(232)
                    end
                end,
            },

            ['Matata'] = quest:progressEvent(226),
        },
    },
}

return quest
