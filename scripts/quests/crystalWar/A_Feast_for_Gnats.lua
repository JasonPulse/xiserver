-----------------------------------
-- A Feast for Gnats
-----------------------------------
-- Log ID: 7, Quest ID: 40
-- Robel-Akbel : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_FEAST_FOR_GNATS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Robel-Akbel'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1050)
                end,
            },

            onEventFinish =
            {
                [1050] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        quest:complete(player)
                    end
                end,
            },
        },
    },
}

return quest
