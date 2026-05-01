-----------------------------------
-- Battle on a New Front
-----------------------------------
-- Log ID: 7, Quest ID: 82
-- Lehko_Habhoka : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BATTLE_ON_A_NEW_FRONT)

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
                player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.DRAFTED_BY_THE_DUCHY)
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Lehko_Habhoka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1420)
                end,
            },

            onEventFinish =
            {
                [1420] = function(player, csid, option, npc)
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
