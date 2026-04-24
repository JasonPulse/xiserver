-----------------------------------
-- In a Pickle
-----------------------------------
-- Log ID: 2, Quest ID: 5
-- Chamama
-----------------------------------
local watersID = zones[xi.zone.WINDURST_WATERS]
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.IN_A_PICKLE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Chamama'] =
            {
                onTrigger = function(player, npc)
                    if math.random(1, 2) == 1 then
                        return quest:progressEvent(654, 0, xi.item.RARAB_TAIL)
                    end
                end,
            },

            onEventFinish =
            {
                [654] = function(player, csid, option, npc)
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

        [xi.zone.WINDURST_WATERS] =
        {
            ['Chamama'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(655, 0, xi.item.RARAB_TAIL)
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:getItemCount() ~= 1 or
                        trade:getGil() ~= 0 or
                        not trade:hasItemQty(xi.item.SMOOTH_STONE, 1)
                    then
                        return
                    end

                    local rand = math.random(1, 4)
                    if rand <= 2 then
                        return quest:progressEvent(659)
                    elseif rand == 3 then
                        player:tradeComplete()
                        return quest:progressEvent(657)
                    else
                        player:tradeComplete()
                        return quest:progressEvent(658)
                    end
                end,
            },

            onEventFinish =
            {
                [659] = function(player, csid, option, npc)
                    player:tradeComplete()
                    quest:setMustZone(player)

                    if quest:complete(player) then
                        player:addItem(xi.item.BONE_HAIRPIN)
                        player:messageSpecial(watersID.text.ITEM_OBTAINED, xi.item.BONE_HAIRPIN)
                        npcUtil.giveCurrency(player, 'gil', 200)
                        player:addFame(xi.fameArea.WINDURST, 75)
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
            ['Chamama'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:progressEvent(660)
                    elseif quest:getVar(player, 'Repeat') == 1 then
                        return quest:progressEvent(655, 0, xi.item.RARAB_TAIL)
                    elseif math.random(1, 2) == 1 then
                        return quest:progressEvent(661)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Repeat') ~= 1 or
                        trade:getItemCount() ~= 1 or
                        trade:getGil() ~= 0 or
                        not trade:hasItemQty(xi.item.SMOOTH_STONE, 1)
                    then
                        return
                    end

                    local rand = math.random(1, 4)
                    if rand <= 2 then
                        return quest:progressEvent(662, 200)
                    elseif rand == 3 then
                        player:tradeComplete()
                        return quest:progressEvent(657)
                    else
                        player:tradeComplete()
                        return quest:progressEvent(658)
                    end
                end,
            },

            onEventFinish =
            {
                [661] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:setVar(player, 'Repeat', 1)
                    end
                end,

                [662] = function(player, csid, option, npc)
                    player:tradeComplete()
                    quest:setMustZone(player)
                    player:addGil(xi.settings.main.GIL_RATE * 200)
                    player:addFame(xi.fameArea.WINDURST, 8)
                    quest:setVar(player, 'Repeat', 0)
                end,
            },
        },
    },
}

return quest
