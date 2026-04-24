-----------------------------------
-- Indomitable Spirit
-----------------------------------
-- Log ID: 5, Quest ID: 201
-- Irmilant !pos 3.78 9.54 56.21 247
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.INDOMITABLE_SPIRIT)

quest.reward =
{
    item     = 17011,
    fameArea = xi.fameArea.SELBINA_RABAO,
    fame     = 100,
    title    = xi.title.INDOMITABLE_FISHER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasKeyItem(xi.ki.SERPENT_RUMORS)
        end,

        [xi.zone.RABAO] =
        {
            ['Irmilant'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(131)
                end,
            },

            onEventFinish =
            {
                [131] = function(player, csid, option, npc)
                    quest:begin(player)
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
            ['Irmilant'] =
            {
                onTrigger = function(player, npc)
                    local timer = player:getCharVar('IndomitableSpiritTimer')
                    if timer ~= 0 and timer > GetSystemTime() then
                        return quest:progressEvent(133)
                    elseif timer ~= 0 then
                        return quest:progressEvent(134)
                    end
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { 1837, 1826 }) then
                        return quest:progressEvent(132)
                    end
                end,
            },

            onEventFinish =
            {
                [132] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:setCharVar('IndomitableSpiritTimer', NextConquestTally())
                end,

                [134] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:setCharVar('IndomitableSpiritTimer', 0)
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
            ['Irmilant'] = quest:progressEvent(135),
        },
    },
}

return quest
