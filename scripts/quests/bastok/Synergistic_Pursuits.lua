-----------------------------------
-- Synergistic Pursuits
-----------------------------------
-- Log ID: 1, Quest ID: 89
-- Hildolf : Metalworks (F-8)
-----------------------------------
-- Retail: grandfathered 2012-03 — original Synergy Crucible unlock.
-- On this server: accept from Hildolf, receive Synergy Crucible KI.
-- First in the Synergy chain; unlocks The Wondrous Whatchamacallit.
-- CSIDs best-guess; verify with !cs in-game.
-----------------------------------
local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.SYNERGUSTIC_PURSUITS)

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
                player:getFameLevel(xi.fameArea.BASTOK) >= 1
        end,

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(700)
                end,
            },

            onEventFinish =
            {
                [700] = function(player, csid, option, npc)
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

        [xi.zone.METALWORKS] =
        {
            ['Hildolf'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(701)
                end,
            },

            onEventFinish =
            {
                [701] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        npcUtil.giveKeyItem(player, xi.ki.SYNERGY_CRUCIBLE)
                    end
                end,
            },
        },
    },
}

return quest
