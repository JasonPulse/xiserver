-----------------------------------
-- Escort for Hire (Bastok)
-----------------------------------
-- Log ID: 1, Quest ID: 70
-- Trilok : Port Bastok (D-6), event 44 default
-- Olavia : The Crawlers' Nest
-----------------------------------
-- Retail: timed escort through Crawlers' Nest with random paths.
-- Simplified for 4-player server: accept → zone into Crawlers' Nest,
-- speak to Olavia for the Completion certificate, return to Trilok.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local MIRATETES_MEMOIRS = xi.item.MIRATETES_MEMOIRS

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
}

local function canAccept(player)
    return player:getFameLevel(xi.fameArea.BASTOK) >= 6
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                canAccept(player) and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_BASTOK] =
        {
            ['Trilok'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(45)
                end,
            },

            onEventFinish =
            {
                [45] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                            player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)
                        else
                            quest:begin(player)
                        end
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.CRAWLERS_NEST] =
        {
            ['Olavia'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(52)
                    end
                end,
            },

            onEventFinish =
            {
                [52] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE)
                end,
            },
        },

        [xi.zone.PORT_BASTOK] =
        {
            ['Trilok'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(46)
                    end
                end,
            },

            onEventFinish =
            {
                [46] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)
                        if player:getCharVar('EscortForHireBastokCleared') == 0 then
                            player:setCharVar('EscortForHireBastokCleared', 1)
                            player:addGil(10000)
                            player:messageSpecial(zones[xi.zone.PORT_BASTOK].text.GIL_OBTAINED, 10000)
                        end
                        player:addItem(MIRATETES_MEMOIRS)
                        player:messageSpecial(zones[xi.zone.PORT_BASTOK].text.ITEM_OBTAINED, MIRATETES_MEMOIRS)
                        player:completeQuest(xi.questLog.BASTOK, xi.quest.id.bastok.ESCORT_FOR_HIRE)
                        player:addFame(xi.fameArea.BASTOK, 10)
                    end
                end,
            },
        },
    },
}

return quest
