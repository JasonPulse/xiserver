-----------------------------------
-- Gullible's Travels
-----------------------------------
-- Log ID: 5, Quest ID: 8
-- Magriffon (Kazham)
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.GULLIBLES_TRAVELS)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 6
        end,

        [xi.zone.KAZHAM] =
        {
            ['Magriffon'] =
            {
                onTrigger = function(player, npc)
                    local gil = math.random(10, 30) * 1000
                    player:setCharVar('MAGRIFFON_GIL_REQUEST', gil)
                    return quest:progressEvent(144, 0, gil)
                end,
            },

            onEventFinish =
            {
                [144] = function(player, csid, option, npc)
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

        [xi.zone.KAZHAM] =
        {
            ['Magriffon'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(145, 0, player:getCharVar('MAGRIFFON_GIL_REQUEST'))
                end,

                onTrade = function(player, npc, trade)
                    if trade:getGil() >= player:getCharVar('MAGRIFFON_GIL_REQUEST') then
                        return quest:progressEvent(146)
                    end
                end,
            },

            onEventFinish =
            {
                [146] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:delGil(player:getCharVar('MAGRIFFON_GIL_REQUEST'))
                    player:setCharVar('MAGRIFFON_GIL_REQUEST', 0)
                    player:addFame(xi.fameArea.WINDURST, 30)
                    player:setTitle(xi.title.GULLIBLES_TRAVELS)
                    quest:complete(player)
                    player:needToZone(true)
                end,
            },
        },
    },
}

return quest
