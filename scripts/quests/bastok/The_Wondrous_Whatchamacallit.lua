-----------------------------------
-- The Wondrous Whatchamacallit
-----------------------------------
-- Log ID: 1, Quest ID: 90
-- Selliste : Bastok Mines (K-7)
-----------------------------------
-- Retail: trade Astral Matter (synergized from 6 cloister stones).
-- Simplified for 4-player server: speak to Selliste with Synergy Crucible
-- already earned; receive Portafurnace on first visit. Skips the cloister
-- stone hunt — not worth forcing when Synergy is a niche crafting system
-- on a private server.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local PORTAFURNACE = 13078

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.THE_WONDROUS_WHATCHAMACALLIT)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasKeyItem(xi.ki.SYNERGY_CRUCIBLE) and
                player:hasCompletedQuest(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS)
        end,

        [xi.zone.BASTOK_MINES] =
        {
            ['Selliste'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(800)
                end,
            },

            onEventFinish =
            {
                [800] = function(player, csid, option, npc)
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

        [xi.zone.BASTOK_MINES] =
        {
            ['Selliste'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(801)
                end,
            },

            onEventFinish =
            {
                [801] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() > 0 and quest:complete(player) then
                        player:addItem(PORTAFURNACE)
                    end
                end,
            },
        },
    },
}

return quest
