-----------------------------------
-- Catch It If You Can
-----------------------------------
-- Log ID: 2, Quest ID: 21
-- Ohruru !pos -108 -5 94 240
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.CATCH_IT_IF_YOU_CAN)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Ohruru'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 0 then
                        quest:setVar(player, 'Prog', 1)
                        return quest:progressEvent(230)
                    elseif prog == 1 then
                        quest:setVar(player, 'Prog', 2)
                        return quest:progressEvent(253)
                    else
                        return quest:progressEvent(231)
                    end
                end,
            },

            onEventFinish =
            {
                [231] = function(player, csid, option, npc)
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

        [xi.zone.PORT_WINDURST] =
        {
            ['Ohruru'] =
            {
                onTrigger = function(player, npc)
                    local hasAilment = player:hasStatusEffect(xi.effect.MUTE) or
                        player:hasStatusEffect(xi.effect.BANE) or
                        player:hasStatusEffect(xi.effect.PLAGUE)

                    if hasAilment then
                        return quest:progressEvent(246)
                    elseif quest:getMustZone(player) then
                        return quest:progressEvent(255)
                    elseif math.random(1, 2) == 1 then
                        return quest:progressEvent(248)
                    else
                        return quest:progressEvent(251)
                    end
                end,
            },

            onEventFinish =
            {
                [246] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    local gil = 0
                    if player:hasStatusEffect(xi.effect.MUTE) then
                        player:delStatusEffect(xi.effect.MUTE)
                        gil = 1000
                    elseif player:hasStatusEffect(xi.effect.BANE) then
                        player:delStatusEffect(xi.effect.BANE)
                        gil = 1200
                    elseif player:hasStatusEffect(xi.effect.PLAGUE) then
                        player:delStatusEffect(xi.effect.PLAGUE)
                        gil = 1500
                    end

                    npcUtil.giveCurrency(player, 'gil', gil)
                    quest:setMustZone(player)

                    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.CATCH_IT_IF_YOU_CAN) == xi.questStatus.QUEST_ACCEPTED then
                        if quest:complete(player) then
                            player:addFame(xi.fameArea.WINDURST, 75)
                        end
                    else
                        player:addFame(xi.fameArea.WINDURST, 8)
                    end
                end,
            },
        },
    },
}

return quest
