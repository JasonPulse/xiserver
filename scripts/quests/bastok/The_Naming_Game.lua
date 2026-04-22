-----------------------------------
-- The Naming Game
-----------------------------------
-- Log ID: 1, Quest ID: 81
-- Raibaht : Metalworks (G-8), default event 501
-- Trade Ordrynite (item 1728) to Raibaht.
-----------------------------------
-- Retail: 4-segment airship-name picker, repeatable, 4th segment unlocks
-- after 10 clears. Simplified for 4-player server: trade Ordrynite for
-- gil + title. No name picker (the airship already exists on the server
-- with its upstream-default name).
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local ordrynite = 1728

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.THE_NAMING_GAME)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.BASTOK,
    title    = xi.title.HYPER_ULTRA_SONIC_ADVENTURER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 5 and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.HYPER_ACTIVE)
        end,

        [xi.zone.METALWORKS] =
        {
            ['Raibaht'] =
            {
                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHasExactly(trade, ordrynite) then
                        return quest:progressEvent(504)
                    end
                end,
            },

            onEventFinish =
            {
                [504] = function(player, csid, option, npc)
                    player:confirmTrade()
                    local firstClear = player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.THE_NAMING_GAME) ~= xi.questStatus.QUEST_COMPLETED
                    if firstClear then
                        quest:begin(player)
                        if quest:complete(player) then
                            player:addGil(3600)
                            player:messageSpecial(zones[xi.zone.METALWORKS].text.GIL_OBTAINED, 3600)
                        end
                    else
                        -- Repeat: small gil, no title
                        player:addGil(500)
                        player:messageSpecial(zones[xi.zone.METALWORKS].text.GIL_OBTAINED, 500)
                    end
                end,
            },
        },
    },
}

return quest
