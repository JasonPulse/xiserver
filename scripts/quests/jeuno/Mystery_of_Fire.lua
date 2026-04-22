-----------------------------------
-- Mystery of Fire
-----------------------------------
-- Log ID: 3, Quest ID: 33
-- No bg-wiki documentation exists for these 8 Mystery of <Element> quests
-- (see research 2026-04-22). Enum slots 33-40 appear in quests.lua but
-- no retail source. Implemented as a thin private-server stub tied to
-- Laila in Upper Jeuno — accept then speak again to complete for a
-- small gil + thematic crystal reward.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.MYSTERY_OF_FIRE)

quest.reward =
{
    fame     = 10,
    fameArea = xi.fameArea.JEUNO,
    gil      = 1000,
    item     = xi.item.FIRE_CRYSTAL,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.JEUNO) >= 3
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10121)
                end,
            },

            onEventFinish =
            {
                [10121] = function(player, csid, option, npc)
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

        [xi.zone.UPPER_JEUNO] =
        {
            ['Laila'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10122)
                end,
            },

            onEventFinish =
            {
                [10122] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },
}

return quest
