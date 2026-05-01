-----------------------------------
-- The Amazin' Scorpio
-----------------------------------
-- Log ID: 2, Quest ID: 61
-- Soni-Muni            !pos -17.073 1.749 -59.327 241
-- Gottah Maporushanoh
-----------------------------------

local quest = Quest:new(xi.questLog.WINDURST, xi.quest.id.windurst.THE_AMAZIN_SCORPIO)

quest.reward =
{
    fameArea = xi.fameArea.WINDURST,
    fame     = 80,
    gil      = 1500,
    title    = xi.title.GREAT_GRAPPLER_SCORPIO,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.WINDURST) >= 2
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Soni-Muni'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(481, 0, 0, xi.item.SCORPION_STINGER)
                end,
            },

            onEventFinish =
            {
                [481] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Soni-Muni'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(482, 0, 0, xi.item.SCORPION_STINGER)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, xi.item.SCORPION_STINGER) then
                        return quest:progressEvent(484)
                    end
                end,
            },

            ['Gottah_Maporushanoh'] = quest:progressEvent(483),

            onEventFinish =
            {
                [484] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.WINDURST_WOODS] =
        {
            ['Soni-Muni']           = quest:progressEvent(485),
            ['Gottah_Maporushanoh'] = quest:progressEvent(486),
        },
    },
}

return quest
