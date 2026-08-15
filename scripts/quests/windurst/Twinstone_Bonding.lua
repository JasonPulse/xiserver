-----------------------------------
-- Twinstone Bonding
-----------------------------------
-- Log ID: 2, Quest ID: 62
-- Gioh Ajihri    (Windurst Woods)
-- Wani Casdohry  (Windurst Woods)
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.TWINSTONE_BONDING)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 3
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Gioh_Ajihri'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(487, 0, xi.item.TWINSTONE_EARRING)
                end,
            },

            onEventFinish =
            {
                [487] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:setCharVar('GiohAijhriSpokenTo', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED or
                (status == xi.questStatus.QUEST_COMPLETED and not player:needToZone())
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Gioh_Ajihri'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(488, 0, xi.item.TWINSTONE_EARRING)
                end,

                onTrade = function(player, npc, trade)
                    if
                        player:getCharVar('GiohAijhriSpokenTo') == 1 and
                        npcUtil.tradeHas(trade, xi.item.TWINSTONE_EARRING)
                    then
                        return quest:progressEvent(490)
                    end
                end,
            },

            ['Wani_Casdohry'] = quest:progressEvent(489, 0, 13360),

            onEventFinish =
            {
                [488] = function(player, csid, option, npc)
                    player:setCharVar('GiohAijhriSpokenTo', 1)
                end,

                [490] = function(player, csid, option, npc)
                    player:confirmTrade()
                    player:needToZone(true)
                    player:setCharVar('GiohAijhriSpokenTo', 0)

                    if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.TWINSTONE_BONDING) == xi.questStatus.QUEST_ACCEPTED then
                        quest.reward =
                        {
                            item     = 17154,
                            fame     = 80,
                            fameArea = xi.fameArea.WINDURST,
                            title    = xi.title.BOND_FIXER,
                        }

                        quest:complete(player)
                    else
                        player:addFame(xi.fameArea.WINDURST, 10)
                        npcUtil.giveCurrency(player, 'gil', 900)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and player:needToZone()
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Gioh_Ajihri'] = quest:progressEvent(491, 0, xi.item.TWINSTONE_EARRING),
            ['Wani_Casdohry'] = quest:progressEvent(492, 0, 13360),
        },
    },
}

return quest
