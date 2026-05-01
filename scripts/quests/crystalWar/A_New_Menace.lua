-----------------------------------
-- A New Menace
-----------------------------------
-- Log ID: 7, Quest ID: 87
-- Lehko_Habhoka : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_NEW_MENACE)

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
                player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.REDRAFTED_BY_THE_DUCHY)
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Lehko_Habhoka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1470)
                end,
            },

            onEventFinish =
            {
                [1470] = function(player, csid, option, npc)
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
