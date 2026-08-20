-----------------------------------
-- Howl from the Heavens
-----------------------------------
-- Log ID: 7, Quest ID: 54
-- Robel-Akbel : WINDURST WATERS [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.HOWL_FROM_THE_HEAVENS)

quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.SANDORIA,
    -- bg-wiki |Title=The Moon's Companion -- nothing granted it.
    title = xi.title.THE_MOONS_COMPANION,
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
                    return quest:progressEvent(1140)
                end,
            },

            onEventFinish =
            {
                [1140] = function(player, csid, option, npc)
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
