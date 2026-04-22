-----------------------------------
-- Escort for Hire (Windurst)
-----------------------------------
-- Log ID: 2, Quest ID: 88
-- Dehn Harzhapan : Port Windurst (G-6), default event 10018
-- Wanzo-Unzozo   : Garlaige Citadel, default event 60
-----------------------------------
-- Retail: timed escort through Garlaige Citadel with Banishing Gate
-- mechanics. Simplified for 4-player server: accept from Dehn → zone
-- into Garlaige Citadel → speak to Wanzo-Unzozo for Completion certificate
-- → return to Dehn. First clear 10k gil + Miratete's Memoirs, repeats
-- Memoirs only. No hard weekly gate.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local MIRATETES_MEMOIRS = xi.item.MIRATETES_MEMOIRS

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.WINDURST,
}

local function canAccept(player)
    return player:getFameLevel(xi.fameArea.WINDURST) >= 6
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                canAccept(player) and
                not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE)
        end,

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10019)
                end,
            },

            onEventFinish =
            {
                [10019] = function(player, csid, option, npc)
                    if option == 1 then
                        if player:getQuestStatus(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE) == xi.questStatus.QUEST_COMPLETED then
                            player:addQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)
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

        [xi.zone.GARLAIGE_CITADEL] =
        {
            ['Wanzo-Unzozo'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(61)
                    end
                end,
            },

            onEventFinish =
            {
                [61] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.COMPLETION_CERTIFICATE)
                end,
            },
        },

        [xi.zone.PORT_WINDURST] =
        {
            ['Dehn_Harzhapan'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.COMPLETION_CERTIFICATE) then
                        return quest:progressEvent(10020)
                    end
                end,
            },

            onEventFinish =
            {
                [10020] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 then
                        player:delKeyItem(xi.ki.COMPLETION_CERTIFICATE)
                        if player:getCharVar('EscortForHireWindurstCleared') == 0 then
                            player:setCharVar('EscortForHireWindurstCleared', 1)
                            player:addGil(10000)
                            player:messageSpecial(zones[xi.zone.PORT_WINDURST].text.GIL_OBTAINED, 10000)
                        end
                        player:addItem(MIRATETES_MEMOIRS)
                        player:messageSpecial(zones[xi.zone.PORT_WINDURST].text.ITEM_OBTAINED, MIRATETES_MEMOIRS)
                        player:completeQuest(xi.questLog.WINDURST, xi.quest.id.windurst.ESCORT_FOR_HIRE)
                        player:addFame(xi.fameArea.WINDURST, 10)
                    end
                end,
            },
        },
    },
}

return quest
