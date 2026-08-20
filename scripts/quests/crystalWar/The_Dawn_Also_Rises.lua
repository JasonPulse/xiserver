-----------------------------------
-- The Dawn Also Rises
-----------------------------------
-- Log ID: 7, Quest ID: 74
-- Adelbrecht : BASTOK MARKETS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.THE_DAWN_ALSO_RISES)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    -- bg-wiki |Title=Light of Dawn -- nothing granted it.
    title = xi.title.LIGHT_OF_DAWN,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.CHAMPION_OF_THE_DAWN)
        end,

        [xi.zone.BASTOK_MARKETS_S] =
        {
            ['Adelbrecht'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1330)
                end,
            },

            onEventFinish =
            {
                [1330] = function(player, csid, option, npc)
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
