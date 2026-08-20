-----------------------------------
-- At Journeys End
-----------------------------------
-- Log ID: 7, Quest ID: 63
-- Lehko_Habhoka : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.AT_JOURNEYS_END)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    -- bg-wiki |Title=Star in the Azure Sky -- nothing granted it.
    title = xi.title.STAR_IN_THE_AZURE_SKY,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.WINDURST_WATERS_S] =
        {
            ['Lehko_Habhoka'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1210)
                end,
            },

            onEventFinish =
            {
                [1210] = function(player, csid, option, npc)
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
