-----------------------------------
-- Fly High
-----------------------------------
-- Log ID: 4, Quest ID: 71
-- Ferchinne (Tavnazian Safehold)
-----------------------------------

local quest = Quest:new(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.FLY_HIGH)

quest.reward =
{
    item = xi.item.MISTMELT,
}

local function copFlag(player)
    return player:getCurrentMission(xi.mission.log_id.COP) == xi.mission.id.cop.THE_SAVAGE or
        player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.THE_SAVAGE)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and copFlag(player)
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Ferchinne'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(241)
                end,
            },

            onEventFinish =
            {
                [241] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Ferchinne'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(242)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { xi.item.HIPPOGRYPH_TAILFEATHER, 2 } }) then
                        return quest:progressEvent(243)
                    end
                end,
            },

            onEventFinish =
            {
                [243] = function(player, csid, option, npc)
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

        [xi.zone.TAVNAZIAN_SAFEHOLD] =
        {
            ['Ferchinne'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(244)
                end,

                onTrade = function(player, npc, trade)
                    if npcUtil.tradeHas(trade, { { xi.item.HIPPOGRYPH_TAILFEATHER, 2 } }) then
                        return quest:progressEvent(245)
                    end
                end,
            },

            onEventFinish =
            {
                [245] = function(player, csid, option, npc)
                    if npcUtil.giveItem(player, xi.item.MISTMELT) then
                        player:confirmTrade()
                    end
                end,
            },
        },
    },
}

return quest
