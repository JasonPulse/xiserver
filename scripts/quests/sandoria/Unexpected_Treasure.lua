-----------------------------------
-- Unexpected Treasure
-----------------------------------
-- Log ID: 0, Quest ID: 70
-- Morunaude : Northern San d'Oria (F-8) — furniture shop, event 634 default
-- Calovour  : Northern San d'Oria (M-6) — Cathedral, event 633 default
-- CSIDs below are best-guess from client event dump — verify with !cs in-game.
-- Retail flow used a Mog House "wait" step via the Moogle; simplified here
-- to a direct Cupboard trade + Mistletoe trade for a 4-player private server.
-----------------------------------
local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.UNEXPECTED_TREASURE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    gil      = 12000,
}

-- Prog states
--  0 = accepted, bring a Cupboard to Morunaude
--  1 = Cupboard traded, talk to Calovour
--  2 = Calovour met, trade Mistletoe

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 4
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Morunaude'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(635)
                end,
            },

            onEventFinish =
            {
                [635] = function(player, csid, option, npc)
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

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Morunaude'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 0 and
                        npcUtil.tradeHasExactly(trade, xi.item.CUPBOARD)
                    then
                        return quest:progressEvent(636)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') >= 1 then
                        return quest:event(978)
                    else
                        return quest:event(635)
                    end
                end,
            },

            ['Calovour'] =
            {
                onTrade = function(player, npc, trade)
                    if
                        quest:getVar(player, 'Prog') == 2 and
                        npcUtil.tradeHasExactly(trade, xi.item.SPRIG_OF_MISTLETOE)
                    then
                        return quest:progressEvent(639)
                    end
                end,

                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Prog') == 1 then
                        return quest:progressEvent(637)
                    elseif quest:getVar(player, 'Prog') == 2 then
                        return quest:event(638)
                    end
                end,
            },

            onEventFinish =
            {
                [636] = function(player, csid, option, npc)
                    player:confirmTrade()
                    npcUtil.giveKeyItem(player, xi.ki.SMALL_TEACUP)
                    quest:setVar(player, 'Prog', 1)
                end,

                [637] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.SMALL_TEACUP)
                    quest:setVar(player, 'Prog', 2)
                end,

                [639] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
