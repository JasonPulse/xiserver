-----------------------------------
-- Sorcery of the North
-----------------------------------
-- Log ID: 0, Quest ID: 83
-- Eperdur        !pos 129 -6 96 231
-- Treasure Chest !zone 204 (Fei'Yin, handled by xi.treasure framework)
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.SORCERY_OF_THE_NORTH)

quest.reward =
{
    fameArea = xi.fameArea.SANDORIA,
    item     = xi.item.SCROLL_OF_TELEPORT_VAHZL,
    fame     = 30,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.HEALING_THE_LAND) == xi.questStatus.QUEST_COMPLETED and
                not player:needToZone() and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 4
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Eperdur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(685)
                end,
            },

            onEventFinish =
            {
                [685] = function(player, csid, option, npc)
                    if option == 0 then
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

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Eperdur'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.FEIYIN_MAGIC_TOME) then
                        return quest:progressEvent(687)
                    else
                        return quest:progressEvent(686)
                    end
                end,
            },

            onEventFinish =
            {
                [687] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.FEIYIN_MAGIC_TOME)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED and player:needToZone()
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Eperdur'] = quest:progressEvent(684),
        },
    },
}

return quest
