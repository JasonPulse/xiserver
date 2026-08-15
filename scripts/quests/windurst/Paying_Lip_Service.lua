-----------------------------------
-- Paying Lip Service
-----------------------------------
-- Log ID: 2, Quest ID: 60
-- Tapoh Lihzeh !pos 51.011 -3.749 54.402 241
-----------------------------------

-- bg-wiki "Paying Lip Service": Windurst fame 1, trade 3 Beehive Chips (150 gil)
-- or 2 Remi Shells (200 gil). Repeatable. Title Kisser Make-Upper.
-- Explicitly: "Will not start quest if Chocobilious is active."
local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.PAYING_LIP_SERVICE)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 60,
    title    = xi.title.KISSER_MAKE_UPPER,
}

local beehiveGil = 150
local remiGil    = 200

local function rewardBeehive()
    return xi.settings.main.GIL_RATE * beehiveGil
end

local function rewardRemi()
    return xi.settings.main.GIL_RATE * remiGil
end

quest.sections =
{
    {
        check = function(player, status, vars)
            -- bg-wiki: will not start while Chocobilious is active. That quest is
            -- implemented here (windurst/Chocobilious.lua), so the conflict is
            -- reachable.
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CHOCOBILIOUS) ~= xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Tapoh_Lihzeh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(477, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, rewardBeehive(), rewardRemi())
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
                    return quest:progressEvent(478, 0, xi.item.BEEHIVE_CHIP, xi.item.REMI_SHELL, rewardBeehive(), rewardRemi())
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
