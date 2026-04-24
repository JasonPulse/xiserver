-----------------------------------
-- Trial Size Trial by Water
-----------------------------------
-- Log ID: 5, Quest ID: 148
-- Verctissa !pos -13 1 -20 252
-----------------------------------
local norgID = zones[xi.zone.NORG]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_SIZE_TRIAL_BY_WATER)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20 and
                player:getMainJob() == xi.job.SMN and
                player:getFameLevel(xi.fameArea.NORG) >= 2
        end,

        [xi.zone.NORG] =
        {
            ['Verctissa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(199, 0, xi.item.MINI_TUNING_FORK_OF_WATER, 2, 20)
                end,
            },

            onEventFinish =
            {
                [199] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(norgID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WATER)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_WATER)
                            player:messageSpecial(norgID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WATER)
                        end
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Verctissa'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.MINI_TUNING_FORK_OF_WATER) then
                        return quest:progressEvent(111)
                    else
                        return quest:progressEvent(203, 0, xi.item.MINI_TUNING_FORK_OF_WATER, 2, 20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.MINI_TUNING_FORK_OF_WATER, 1) and
                        player:getMainJob() == xi.job.SMN
                    then
                        return quest:progressEvent(200, 0, xi.item.MINI_TUNING_FORK_OF_WATER, 2, 20)
                    end
                end,
            },

            onEventFinish =
            {
                [200] = function(player, csid, option, npc)
                    if option == 1 then
                        xi.teleport.to(player, xi.teleport.id.CLOISTER_OF_TIDES)
                    end
                end,

                [203] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(norgID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WATER)
                        else
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_WATER)
                            player:messageSpecial(norgID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WATER)
                        end
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Verctissa'] = quest:progressEvent(202),
        },
    },
}

return quest
