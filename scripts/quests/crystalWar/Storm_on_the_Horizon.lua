-----------------------------------
-- Storm on the Horizon
-----------------------------------
-- Log ID: 7, Quest ID: 35
-- Klara : BASTOK MARKETS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.STORM_ON_THE_HORIZON)

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

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Klara'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1020)
                end,
            },

            onEventFinish =
            {
                [1020] = function(player, csid, option, npc)
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
