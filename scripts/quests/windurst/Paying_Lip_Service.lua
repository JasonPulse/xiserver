-----------------------------------
-- Paying Lip Service
-----------------------------------
-- Log ID: 2, Quest ID: 60
-- Tapoh Lihzeh !pos 51.011 -3.749 54.402 241
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.PAYING_LIP_SERVICE)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 60,
    title    = xi.title.KISSER_MAKE_UPPER,
}

local beehiveGil = 150
local remiGil    = 200

local function rewardBeehive(player)
    return xi.settings.main.GIL_RATE * beehiveGil
end

local function rewardRemi(player)
    return xi.settings.main.GIL_RATE * remiGil
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Tapoh_Lihzeh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(477, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, rewardBeehive(player), rewardRemi(player))
                end,
            },

            onEventFinish =
            {
                [477] = function(player, csid, option, npc)
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
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Tapoh_Lihzeh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(478, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, rewardBeehive(player), rewardRemi(player))
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { xi.item.BEEHIVE_CHIP, 3 } }) then
                        return quest:progressEvent(479, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, 0, 0)
                    elseif npcUtil.tradeHas(trade, { { xi.item.REMI_SHELL, 2 } }) then
                        return quest:progressEvent(479, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, 0, 1)
                    end
                end,
            },

            onEventFinish =
            {
                [479] = function(player, csid, option, npc)
                    local gil = option == 1 and remiGil or beehiveGil
                    player:confirmTrade()
                    npcUtil.giveCurrency(player, 'gil', gil)

                    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.PAYING_LIP_SERVICE) == xi.questStatus.QUEST_ACCEPTED then
                        quest:complete(player)
                    else
                        player:addFame(xi.fameArea.WINDURST, 8)
                    end
                end,
            },
        },
    },
}

return quest
