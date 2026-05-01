-----------------------------------
-- Trial Size Trial by Wind
-----------------------------------
-- Log ID: 5, Quest ID: 197
-- Rahi Fohlatti !pos -17 7 -10 247
-----------------------------------
local rabaoID = zones[xi.zone.RABAO]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.TRIAL_SIZE_TRIAL_BY_WIND)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 20 and
                player:getMainJob() == xi.job.SMN and
                player:getFameLevel(xi.fameArea.SELBINA_RABAO) >= 2
        end,

        [xi.zone.RABAO] =
        {
            ['Rahi_Fohlatti'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(108, 0, xi.item.MINI_TUNING_FORK_OF_WIND, 3, 20)
                end,
            },

            onEventFinish =
            {
                [108] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(rabaoID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WIND)
                        else
                            quest:begin(player)
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_WIND)
                            player:messageSpecial(rabaoID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WIND)
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

        [xi.zone.RABAO] =
        {
            ['Rahi_Fohlatti'] =
            {
                onTrigger = function(player, npc)
                    if player:hasItem(xi.item.MINI_TUNING_FORK_OF_WIND) then
                        return quest:progressEvent(68)
                    else
                        return quest:progressEvent(112, 0, xi.item.MINI_TUNING_FORK_OF_WIND, 3, 20)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.MINI_TUNING_FORK_OF_WIND, 1) and
                        player:getMainJob() == xi.job.SMN
                    then
                        return quest:progressEvent(109, 0, xi.item.MINI_TUNING_FORK_OF_WIND, 3, 20)
                    end
                end,
            },

            onEventFinish =
            {
                [109] = function(player, csid, option, npc)
                    if option == 1 then
                        xi.teleport.to(player, xi.teleport.id.CLOISTER_OF_GALES)
                    end
                end,

                [112] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getFreeSlotsCount() == 0 then
                            player:messageSpecial(rabaoID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WIND)
                        else
                            player:addItem(xi.item.MINI_TUNING_FORK_OF_WIND)
                            player:messageSpecial(rabaoID.text.ITEM_OBTAINED, xi.item.MINI_TUNING_FORK_OF_WIND)
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

        [xi.zone.RABAO] =
        {
            ['Rahi_Fohlatti'] = quest:progressEvent(111),
        },
    },
}

return quest
