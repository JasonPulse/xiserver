-----------------------------------
-- Greetings to the Guardian
-----------------------------------
-- Log ID: 5, Quest ID: 2
-- Hari Pakhroib (Kazham)
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.GREETINGS_TO_THE_GUARDIAN)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 7
        end,

        [xi.zone.KAZHAM] =
        {
            ['Hari_Pakhroib'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(68, 4596, 4596, 4596)
                end,
            },

            onEventFinish =
            {
                [68] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        player:setCharVar('PamamaVar', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                (status == xi.questStatus.QUEST_COMPLETED and not player:needToZone())
        end,

        [xi.zone.KAZHAM] =
        {
            ['Hari_Pakhroib'] =
            {
                onTrigger = function(player, npc)
                    local pamamas = player:getCharVar('PamamaVar')

                    if pamamas >= 1 then
                        return quest:progressEvent(71)
                    elseif player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.GREETINGS_TO_THE_GUARDIAN) == xi.questStatus.QUEST_ACCEPTED then
                        return quest:progressEvent(69, 0, 4596)
                    else
                        return quest:progressEvent(72)
                    end
                end,
            },

            onEventFinish =
            {
                [71] = function(player, csid, option, npc)
                    local pamamas = player:getCharVar('PamamaVar')
                    local status = player:getQuestStatus(xi.questLog.OUTLANDS, xi.quest.id.outlands.GREETINGS_TO_THE_GUARDIAN)

                    if status == xi.questStatus.QUEST_ACCEPTED and pamamas == 1 then
                        npcUtil.giveCurrency(player, 'gil', 5000)
                        if quest:complete(player) then
                            player:addFame(xi.fameArea.WINDURST, 100)
                            player:addTitle(xi.title.KAZHAM_CALLER)
                        end
                        player:setCharVar('PamamaVar', 0)
                        player:needToZone(true)
                    elseif pamamas == 2 then
                        npcUtil.giveCurrency(player, 'gil', 5000)
                        player:addFame(xi.fameArea.WINDURST, 30)
                        player:setCharVar('PamamaVar', 0)
                        player:needToZone(true)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and player:needToZone()
        end,

        [xi.zone.KAZHAM] =
        {
            ['Hari_Pakhroib'] = quest:progressEvent(72),
        },
    },
}

return quest
