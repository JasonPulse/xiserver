-----------------------------------
-- Over the Hills and Far Away
-----------------------------------
-- Log ID: 0, Quest ID: 112
-- Antreneau         : !pos -71 -5 -39 232
-- qm_moblin_hotrok  : !pos -299 -62 -18 116
-----------------------------------
local uleguerandID = zones[xi.zone.ULEGUERAND_RANGE]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.OVER_THE_HILLS_AND_FAR_AWAY)

quest.reward =
{
    fameArea = xi.fameArea.SANDORIA,
    keyItem  = xi.ki.MAP_OF_THE_ULEGUERAND_RANGE,
    gil      = 2000,
    exp      = 2000,
    fame     = 30,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.A_TASTE_FOR_MEAT) == xi.questStatus.QUEST_COMPLETED and
                player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.THE_MEDICINE_WOMAN) == xi.questStatus.QUEST_COMPLETED and
                player:getCharVar('Quest[0][100]Option') == 0 and
                player:getCharVar('DiaryPage') >= 4 and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 8
        end,

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Antreneau'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(725)
                end,
            },

            onEventFinish =
            {
                [725] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Antreneau'] = quest:event(726):replaceDefault(),
        },

        [xi.zone.ULEGUERAND_RANGE] =
        {
            ['qm_moblin_hotrok'] =
            {
                onTrigger = function(player, npc)
                    player:messageSpecial(uleguerandID.text.SOMETHING_GLITTERING)
                    player:messageSpecial(uleguerandID.text.WHAT_LIES_BENEATH, 0, xi.item.MOBLIN_HOTROK)
                end,

                onTrade = function(player, npc, trade)
                    if not npcUtil.tradeHas(trade, xi.item.MOBLIN_HOTROK) then
                        return
                    end

                    local recognizes = player:getMissionStatus(xi.mission.log_id.COP, xi.mission.status.COP.LOUVERANCE) == 14
                    local isCompanion = player:hasTitle(xi.title.COMPANION_OF_LOUVERANCE) or
                        player:hasTitle(xi.title.TRUE_COMPANION_OF_LOUVERANCE)

                    if recognizes and isCompanion then
                        return quest:progressEvent(10, 0, 1729, xi.ki.MAP_OF_THE_ULEGUERAND_RANGE, 0, 0, 1, 0)
                    elseif recognizes then
                        return quest:progressEvent(10, 0, 1729, xi.ki.MAP_OF_THE_ULEGUERAND_RANGE, 1, 0, 1, 0)
                    elseif isCompanion then
                        return quest:progressEvent(10, 0, 1729, xi.ki.MAP_OF_THE_ULEGUERAND_RANGE, 0, 1, 0, 0)
                    else
                        return quest:progressEvent(10, 0, 1729, xi.ki.MAP_OF_THE_ULEGUERAND_RANGE, 1, 0, 0, 0)
                    end
                end,
            },

            onEventFinish =
            {
                [10] = function(player, csid, option, npc)
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

        [xi.zone.PORT_SAN_DORIA] =
        {
            ['Antreneau'] = quest:event(727):replaceDefault(),
        },

        [xi.zone.ULEGUERAND_RANGE] =
        {
            ['qm_moblin_hotrok'] =
            {
                onTrigger = function(player, npc)
                    player:messageSpecial(uleguerandID.text.NOTHING_OUT_OF_ORDINARY)
                end,
            },
        },
    },
}

return quest
