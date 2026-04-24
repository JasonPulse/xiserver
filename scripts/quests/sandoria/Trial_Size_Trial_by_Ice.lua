-----------------------------------
-- Trial Size Trial by Ice
-----------------------------------
-- Log ID: 0, Quest ID: 107
-- Castilchat !pos -186 0 107 231
-----------------------------------
local northernSandyID = zones[xi.zone.NORTHERN_SAN_DORIA]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.TRIAL_SIZE_TRIAL_BY_ICE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20 and
                player:getMainJob() == xi.job.SMN and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 2
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Castilchat'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(733, 0, xi.item.MINI_TUNING_FORK_OF_ICE, 4, 20)
                end,
            },

            onEventFinish =
            {
                [733] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(northernSandyID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_ICE)
                            player:messageSpecial(northernSandyID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
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

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Castilchat'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.MINI_TUNING_FORK_OF_ICE) then
                        return quest:progressEvent(708)
                    else
                        return quest:progressEvent(737, 0, xi.item.MINI_TUNING_FORK_OF_ICE, 4, 20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.MINI_TUNING_FORK_OF_ICE, 1) and
                        trade:getItemCount() == 1 and
                        player:getMainJob() == xi.job.SMN
                    then
                        return quest:progressEvent(734, 0, xi.item.MINI_TUNING_FORK_OF_ICE, 4, 20)
                    end
                end,
            },

            onEventFinish =
            {
                [734] = function(player, csid, option, npc)
                    if option == 0 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(northernSandyID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
                        else
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_ICE)
                            player:messageSpecial(northernSandyID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
                        end
                    elseif option == 1 then
                        xi.teleport.to(player, xi.teleport.id.CLOISTER_OF_FROST)
                    end
                end,

                [737] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(northernSandyID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
                    else
                        player:addItem(xi.item.MINI_TUNING_FORK_OF_ICE)
                        player:messageSpecial(northernSandyID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_ICE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Castilchat'] = quest:progressEvent(736),
        },
    },
}

return quest
