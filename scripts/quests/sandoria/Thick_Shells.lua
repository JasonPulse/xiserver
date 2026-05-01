-----------------------------------
-- Thick Shells
-----------------------------------
-- Log ID: 0, Quest ID: 117
-- Vounebariont (Port San d'Oria)
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.THICK_SHELLS)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 2
        end,

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Vounebariont'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(516)
                end,
            },

            onEventFinish =
            {
                [516] = function(player, csid, option, npc)
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

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Vounebariont'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(516)
                end,

                onTrade = function(player, npc, trade)
                    if
                        trade:hasItemQty(xi.item.BEETLE_SHELL, 5) and
                        trade:getItemCount() == 5
                    then
                        return quest:progressEvent(514)
                    end
                end,
            },

            onEventFinish =
            {
                [514] = function(player, csid, option, npc)
                    player:tradeComplete()
                    player:addTitle(xi.title.BUG_CATCHER)
                    npcUtil.giveCurrency(player, 'gil', 750)

                    if player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.THICK_SHELLS) == xi.questStatus.QUEST_ACCEPTED then
                        if quest:complete(player) then
                            player:addFame(xi.fameArea.SANDORIA, 30)
                        end
                    else
                        player:addFame(xi.fameArea.SANDORIA, 5)
                    end
                end,
            },
        },
    },
}

return quest
