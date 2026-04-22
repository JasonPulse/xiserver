-----------------------------------
-- A Proper Burial
-----------------------------------
-- Log ID: 1, Quest ID: 87
-- Offa (present)  : Bastok Markets (F-10), default event 124
-- Offa (past)     : Bastok Markets [S], same grid
-----------------------------------
-- Retail: single quest with 3 internal stages shuttling between present
-- and past Bastok Markets. Trade Fish Bones at one stage, receive
-- Rolanberry, then Withered Berry at the end.
-- Simplified for 4-player server: preserve the 3-stage progression via
-- Prog var, but drop one of the present/past branches — pick the
-- "Somewhere in the City" path which only needs Fish Bones traded once.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local WITHERED_BERRY = 5675

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.A_PROPER_BURIAL)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.BASTOK,
    item     = WITHERED_BERRY,
}

-- Prog
-- 0 = accepted, find past Offa
-- 1 = past Offa met, return to present Offa
-- 2 = trade Fish Bones to present Offa
-- 3 = back to past Offa for Rolanberry
-- 4 = trade Rolanberry back to present Offa for Withered Berry

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Offa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(125)
                end,
            },

            onEventFinish =
            {
                [125] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Offa'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 3 and
                        npcUtil.tradeHasExactly(trade, xi.item.ROLANBERRY)
                    then
                        return quest:progressEvent(128)
                    end
                end,

                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 0 then
                        return quest:progressEvent(126)
                    elseif prog == 3 then
                        return quest:event(127)
                    end
                end,
            },

            onEventFinish =
            {
                [126] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [128] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:confirmTrade()
                        player:addItem(xi.item.ROLANBERRY)
                        player:messageSpecial(zones[xi.zone.BASTOK_MARKETS_S].text.ITEM_OBTAINED, xi.item.ROLANBERRY)
                        quest:setVar(player, 'Prog', 4)
                    end
                end,
            },
        },

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Offa'] =
            {
                onTrade = function(player, npc, trade)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 2 and npcUtil.tradeHasExactly(trade, xi.item.SET_OF_FISH_BONES) then
                        return quest:progressEvent(129)
                    elseif prog == 4 and npcUtil.tradeHasExactly(trade, xi.item.ROLANBERRY) then
                        return quest:progressEvent(130)
                    end
                end,

                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')
                    if prog == 1 then
                        return quest:progressEvent(131)
                    elseif prog == 2 then
                        return quest:event(132)
                    elseif prog == 4 then
                        return quest:event(133)
                    end
                end,
            },

            onEventFinish =
            {
                [131] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 2)
                end,

                [129] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:confirmTrade()
                        player:addItem(xi.item.ROLANBERRY)
                        player:messageSpecial(zones[xi.zone.BASTOK_MARKETS].text.ITEM_OBTAINED, xi.item.ROLANBERRY)
                        quest:setVar(player, 'Prog', 3)
                    end
                end,

                [130] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:confirmTrade()
                        if quest:complete(player) then
                            -- Withered Berry granted via quest.reward.item
                        end
                    end
                end,
            },
        },
    },
}

return quest
