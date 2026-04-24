-----------------------------------
-- Brace for the Unknown
-----------------------------------
-- Log ID: 7, Quest ID: 94
-- Lehko_Habhoka : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BRACE_FOR_THE_UNKNOWN)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.GLIMMER_OF_HOPE)
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Lehko_Habhoka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1540)
                end,
            },

            onEventFinish =
            {
                [1540] = function(player, csid, option, npc)
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
