-----------------------------------
-- Always More Quoth the Ravenous
-----------------------------------
-- Log ID: 9, Quest ID: 88
-- Westerly Breeze !pos 62 32 123 256
-----------------------------------
local westernAdoulinID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.ALWAYS_MORE_QUOTH_THE_RAVENOUS)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 3 and
                not player:needToZone() and
                VanadielUniqueDay() > player:getCharVar('Westerly_Breeze_Wait')
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(3010)
                end,
            },

            onEventFinish =
            {
                [3010] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WESTERN_ADOULIN] =
        {
            ['Westerly_Breeze'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(3011)
                end,

                onTrade = function(player, npc, trade)
                    if trade:getItemCount() ~= 1 or trade:getGil() ~= 0 then
                        return
                    end

                    local item = trade:getItem(0)
                    if not item then
                        return
                    end

                    local itemId = item:getID()
                    local ahCategory = item:getAHCat()

                    if itemId == 4234 then
                        return quest:progressEvent(3012)
                    elseif ahCategory == 58 then
                        if itemId == 4541 then
                            return quest:progressEvent(3013)
                        else
                            return quest:progressEvent(3014)
                        end
                    end
                end,
            },

            onEventFinish =
            {
                [3012] = function(player, csid, option, npc)
                    player:tradeComplete()
                    quest:complete(player)
                    player:addExp(1500 * xi.settings.main.EXP_RATE)
                    player:addCurrency('bayld', 1000 * xi.settings.main.BAYLD_RATE)
                    player:messageSpecial(westernAdoulinID.text.BAYLD_OBTAINED, 1000 * xi.settings.main.BAYLD_RATE)
                    player:addFame(xi.fameArea.ADOULIN, 30)
                    player:setCharVar('Westerly_Breeze_Wait', 0)
                end,

                [3014] = function(player, csid, option, npc)
                    player:tradeComplete()
                end,
            },
        },
    },
}

return quest
