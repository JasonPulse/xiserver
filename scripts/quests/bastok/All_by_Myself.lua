-----------------------------------
-- All by Myself
-----------------------------------
-- Log ID: 1, Quest ID: 76
-- Marin : Bastok Markets (E-10), default event 361
-- Ken   : Dangruf Wadi (level-capped escort NPC)
-----------------------------------
-- Retail: shadow Ken through Dangruf Wadi at level cap 10 while he
-- solo-fights mobs, with 8 progression messages triggered by position.
-- Simplified for 4-player server: accept from Marin → zone into Dangruf
-- Wadi (flag 'Shadowed') → return to Marin for reward. Level cap not
-- imposed on this private server.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.ALL_BY_MYSELF)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.BASTOK,
    gil      = 1500,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.BASTOK) >= 2
        end,

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(362)
                end,
            },

            onEventFinish =
            {
                [362] = function(player, csid, option, npc)
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

        [xi.zone.DANGRUF_WADI] =
        {
            onZoneIn = function(player, prevZone)
                if quest:getVar(player, 'Shadowed') == 0 then
                    quest:setVar(player, 'Shadowed', 1)
                end
                return -1
            end,
        },

        [xi.zone.BASTOK_MARKETS] =
        {
            ['Marin'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Shadowed') == 1 then
                        return quest:progressEvent(363)
                    end
                end,
            },

            onEventFinish =
            {
                [363] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Shadowed', 0)
                    end
                end,
            },
        },
    },
}

return quest
