-----------------------------------
-- The Clockmaster
-----------------------------------
-- Log ID: 3, Quest ID: 21
-- _6s2   : !pos -80 0 104 244
-- Collet : !pos -44 0 107 244
-----------------------------------

local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_CLOCKMASTER)

-- bg-wiki "The Clockmaster" header: |Reward= *[[Time Hammer]] *1,200 [[Gil]].
-- The gil was simply absent -- giveReward does honour a `gil` key
-- (npc_util.lua:592, addGil * GIL_RATE plus the GIL_OBTAINED message), so this
-- was a dropped reward rather than an unsupported one.
quest.reward =
{
    fame     = 30,
    fameArea = xi.fameArea.JEUNO,
    gil      = 1200,
    item     = xi.item.TIME_HAMMER,
    title    = xi.title.TIMEKEEPER,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.SAVE_THE_CLOCK_TOWER) and
                player:getFameLevel(xi.fameArea.JEUNO) >= 5
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['_6s2'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(152)
                end,
            },

            onEventFinish =
            {
                [152] = function(player, csid, option, npc)
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.UPPER_JEUNO] =
        {
            ['_6s2']   = quest:event(110):replaceDefault(),
            ['Collet'] = quest:event(163):replaceDefault(),
        },
    },
}

return quest
