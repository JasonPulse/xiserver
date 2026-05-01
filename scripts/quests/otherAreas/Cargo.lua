-----------------------------------
-- Cargo
-----------------------------------
-- Log ID: 4, Quest ID: 20
-- Vuntar !pos 7 -2 -15 248
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CARGO)

local rolanberryRewards =
{
    [xi.item.ROLANBERRY_881_CE] = { option = 1, gil = 800 },
    [xi.item.ROLANBERRY_874_CE] = { option = 2, gil = 2000 },
    [xi.item.ROLANBERRY_864_CE] = { option = 3, gil = 3000 },
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20
        end,

        [xi.zone.SELBINA] =
        {
            ['Vuntar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(50, 4365)
                end,
            },

            onEventFinish =
            {
                [50] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.SELBINA] =
        {
            ['Vuntar'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(51, 4365)
                end,

                onTrade = function(player, npc, trade)
                    if GetSystemTime() <= player:getCharVar('VuntarCanBuyItem_date') then
                        return quest:progressEvent(1134, 4365)
                    end

                    for itemId, entry in pairs(rolanberryRewards) do
                        if npcUtil.tradeHas(trade, itemId) then
                            quest:setVar(player, 'Payout', entry.gil)
                            return quest:progressEvent(52, entry.option)
                        end
                    end
                end,
            },

            onEventFinish =
            {
                [52] = function(player, csid, option, npc)
                    player:setCharVar('VuntarCanBuyItem_date', JstMidnight())

                    if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CARGO) == xi.questStatus.QUEST_ACCEPTED then
                        if quest:complete(player) then
                            player:addFame(xi.fameArea.SELBINA_RABAO, 30)
                        end
                    end

                    local payout = quest:getVar(player, 'Payout')
                    if payout > 0 then
                        npcUtil.giveCurrency(player, 'gil', payout)
                        player:confirmTrade()
                        quest:setVar(player, 'Payout', 0)
                    end
                end,
            },
        },
    },
}

return quest
