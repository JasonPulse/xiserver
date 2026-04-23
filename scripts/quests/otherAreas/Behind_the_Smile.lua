-----------------------------------
-- Behind the Smile
-----------------------------------
-- Log ID: 4, Quest ID: 77
-- Enaremand : Tavnazian Safehold upper (verified in npc_list.sql)
-- Fyi_Chalmwoh : Mhaura (G-8)
-----------------------------------
-- Retail: Tavnazia → Mhaura → Carpenters' Landing qm → Bullheaded
-- Grosvez NM → Red Oil KI → return. Simplified for 4-player server:
-- accept → speak Fyi_Chalmwoh in Mhaura → complete. NM kill abstracted.
-- Reward: Mannequin Pumps.
-----------------------------------
local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.BEHIND_THE_SMILE)

quest.reward =
{
    fame     = 40,
    fameArea = xi.fameArea.OTHER_AREAS,
    item     = xi.item.MANNEQUIN_PUMPS,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Enaremand'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(400)
                end,
            },

            onEventFinish =
            {
                [400] = function(player, csid, option, npc)
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

        [xi.zone.MHAURA] =
        {
            ['Fyi_Chalmwoh'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(401)
                end,
            },

            onEventFinish =
            {
                [401] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
