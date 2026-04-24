-----------------------------------
-- Trial Size Trial by Lightning
-----------------------------------
-- Log ID: 4, Quest ID: 28
-- Lacia (Mhaura)
-----------------------------------
local mhauraID = zones[xi.zone.MHAURA]
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.TRIAL_SIZE_TRIAL_BY_LIGHTNING)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20 and
                player:getMainJob() == xi.job.SMN and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.MHAURA] =
        {
            ['Lacia'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10025, 0, xi.item.MINI_TUNING_FORK_OF_LIGHTNING, 5, 20)
                end,
            },

            onEventFinish =
            {
                [10025] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(mhauraID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
                            player:messageSpecial(mhauraID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
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

        [xi.zone.MHAURA] =
        {
            ['Lacia'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.MINI_TUNING_FORK_OF_LIGHTNING) then
                        return quest:progressEvent(10018)
                    else
                        return quest:progressEvent(10029, 0, xi.item.MINI_TUNING_FORK_OF_LIGHTNING, 5, 20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.MINI_TUNING_FORK_OF_LIGHTNING, 1) and
                        player:getMainJob() == xi.job.SMN
                    then
                        return quest:progressEvent(10026, 0, xi.item.MINI_TUNING_FORK_OF_LIGHTNING, 5, 20)
                    end
                end,
            },

            onEventFinish =
            {
                [10026] = function(player, csid, option, npc)
                    if option == 1 then
                        xi.teleport.to(player, xi.teleport.id.CLOISTER_OF_STORMS)
                    end
                end,

                [10029] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(mhauraID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
                        else
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
                            player:messageSpecial(mhauraID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_LIGHTNING)
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

        [xi.zone.MHAURA] =
        {
            ['Lacia'] = quest:progressEvent(10028),
        },
    },
}

return quest
