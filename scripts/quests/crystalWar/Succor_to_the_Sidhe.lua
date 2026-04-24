-----------------------------------
-- Succor to the Sidhe
-----------------------------------
-- Log ID: 7, Quest ID: 55
-- Callisto : GRAUBERG [S]
-----------------------------------
-- Crystal War (WotG)-era quest. Simplified for 4-player private server:
-- accept + immediate complete. Retail mechanics (Campaign battles,
-- Voidwatch rifts, NM BCNMs) not implemented on this server.
-----------------------------------
local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.SUCCOR_TO_THE_SIDHE)

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

        [xi.zone.GRAUBERG_S] =
        {
            ['Callisto'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1150)
                end,
            },

            onEventFinish =
            {
                [1150] = function(player, csid, option, npc)
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
