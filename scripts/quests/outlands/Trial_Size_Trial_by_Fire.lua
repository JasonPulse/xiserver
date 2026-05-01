-----------------------------------
-- Trial Size Trial by Fire
-----------------------------------
-- Log ID: 5, Quest ID: 15
-- Dodmos !pos 102.647 -14.999 -97.664 250
-----------------------------------
local kazhamID = zones[xi.zone.KAZHAM]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_SIZE_TRIAL_BY_FIRE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20 and
                player:getMainJob() == xi.job.SMN and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.KAZHAM] =
        {
            ['Dodmos'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(286, 0, xi.item.MINI_TUNING_FORK_OF_FIRE, 0, 20)
                end,
            },

            onEventFinish =
            {
                [286] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(kazhamID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_FIRE)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_FIRE)
                            player:messageSpecial(kazhamID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_FIRE)
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

        [xi.zone.KAZHAM] =
        {
            ['Dodmos'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.MINI_TUNING_FORK_OF_FIRE) then
                        return quest:progressEvent(272)
                    else
                        return quest:progressEvent(290, 0, xi.item.MINI_TUNING_FORK_OF_FIRE, 0, 20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.MINI_TUNING_FORK_OF_FIRE, 1) and
                        player:getMainJob() == xi.job.SMN
                    then
                        return quest:progressEvent(287, 0, xi.item.MINI_TUNING_FORK_OF_FIRE, 0, 20)
                    end
                end,
            },

            onEventFinish =
            {
                [287] = function(player, csid, option, npc)
                    if option == 1 then
                        xi.teleport.to(player, xi.teleport.id.CLOISTER_OF_FLAMES)
                    end
                end,

                [290] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(kazhamID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_FIRE)
                        else
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_FIRE)
                            player:messageSpecial(kazhamID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_FIRE)
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

        [xi.zone.KAZHAM] =
        {
            ['Dodmos'] = quest:progressEvent(289),
        },
    },
}

return quest
