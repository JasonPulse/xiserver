-----------------------------------
-- Something Fishy
-----------------------------------
-- Log ID: 2, Quest ID: 52
-- Tokaka, Port Windurst
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.SOMETHING_FISHY)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Tokaka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(208, 0, xi.item.BASTORE_SARDINE_1)
                end,
            },

            onEventFinish =
            {
                [208] = function(player, csid, option, npc)
                    quest:begin(player)
                    quest:setVar(player, 'Prog', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Tokaka'] =
            {
                onTrigger = function(player, npc)
                    if quest:getMustZone(player) then
                        return quest:progressEvent(211)
                    else
                        return quest:progressEvent(209, 0, xi.item.BASTORE_SARDINE_1)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 1 and
                        not quest:getMustZone(player) and
                        trade:hasItemQty(xi.item.BASTORE_SARDINE_1, 1) and
                        trade:getItemCount() == 1
                    then
                        return quest:progressEvent(210, xi.settings.main.GIL_RATE * 70, xi.item.BASTORE_SARDINE_1)
                    end
                end,
            },

            onEventFinish =
            {
                [209] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [210] = function(player, csid, option, npc)
                    player:tradeComplete()
                    player:addGil(xi.settings.main.GIL_RATE * 70)
                    quest:setVar(player, 'Prog', 0)
                    quest:setMustZone(player)

                    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.SOMETHING_FISHY) == xi.questStatus.QUEST_ACCEPTED then
                        if quest:complete(player) then
                            player:addFame(xi.fameArea.WINDURST, 60)
                        end
                    else
                        player:addFame(xi.fameArea.WINDURST, 10)
                    end
                end,
            },
        },
    },
}

return quest
