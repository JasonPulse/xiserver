-----------------------------------
-- An Undying Pledge
-----------------------------------
-- Log ID: 5, Quest ID: 149
-- Stray Cloud !pos -20.617 1.097 -29.165 252
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.AN_UNDYING_PLEDGE)

quest.reward =
{
    fameArea = xi.fameArea.NORG,
    item     = xi.item.LIGHT_BUCKLER,
    fame     = 50,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.NORG) >= 4
        end,

        [xi.zone.NORG] =
        {
            ['Stray_Cloud'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(225)
                end,
            },

            onEventFinish =
            {
                [225] = function(player, csid, option, npc)
                    quest:begin(player)
                    player:setCharVar('anUndyingPledgeCS', 1)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.NORG] =
        {
            ['Stray_Cloud'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.CALIGINOUS_BLADE) then
                        return quest:progressEvent(227)
                    elseif player:getCharVar('anUndyingPledgeCS') == 1 then
                        return quest:progressEvent(228)
                    elseif player:getCharVar('anUndyingPledgeCS') == 2 then
                        return quest:progressEvent(229)
                    end
                end,
            },

            onEventFinish =
            {
                [227] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.CALIGINOUS_BLADE)
                        player:setCharVar('anUndyingPledgeCS', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.NORG] =
        {
            ['Stray_Cloud'] = quest:progressEvent(230),
        },
    },
}

return quest
