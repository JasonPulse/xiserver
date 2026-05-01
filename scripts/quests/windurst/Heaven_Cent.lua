-----------------------------------
-- Heaven Cent
-----------------------------------
-- Log ID: 2, Quest ID: 49
-- Ropunono : Windurst Waters (F-7), default event 283
-- Iron Door + chest : Maze of Shakhrami (K-9, map 2)
-----------------------------------
-- Retail: trade Ahriman Lens to Ropunono → farm Rusty Key from Wights
-- in Maze of Shakhrami → trade to Iron Door → open chest for Shelling
-- Piece → trade Shelling Piece back to Ropunono. Simplified for 4-player
-- server: zone into Maze of Shakhrami after accepting auto-grants the
-- Shelling Piece (skipping Wight farm + Iron Door interaction). Then
-- return and trade Shelling Piece to Ropunono for reward.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local shellingPiece = 545

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.HEAVEN_CENT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
    gil      = 4800,
    title    = xi.title.NIGHT_SKY_NAVIGATOR,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, xi.item.AHRIMAN_LENS) then
                        return quest:progressEvent(284)
                    end
                end,
            },

            onEventFinish =
            {
                [284] = function(player, csid, option, npc)
                    player:confirmTrade()
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.MAZE_OF_SHAKHRAMI] =
        {
            onZoneIn = function(player, prevZone)
                if
                    quest:getVar(player, 'ShellingGranted') == 0 and
                    player:getFreeSlotsCount() > 0
                then
                    player:addItem(shellingPiece)
                    player:messageSpecial(zones[xi.zone.MAZE_OF_SHAKHRAMI].text.ITEM_OBTAINED, shellingPiece)
                    quest:setVar(player, 'ShellingGranted', 1)
                end

                return -1
            end,
        },

        [xi.zone.WINDURST_WATERS] =
        {
            ['Ropunono'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, shellingPiece) then
                        return quest:progressEvent(285)
                    end
                end,
            },

            onEventFinish =
            {
                [285] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
