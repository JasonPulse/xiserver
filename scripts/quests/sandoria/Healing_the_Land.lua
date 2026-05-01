-----------------------------------
-- Healing the Land
-----------------------------------
-- Log ID: 0, Quest ID: 82
-- Eperdur !pos 129 -6 96 231
-- qm3     !pos -168 1 311 196 (Gusgen Mines)
-----------------------------------
local gusgenID = zones[xi.zone.GUSGEN_MINES]
-----------------------------------

local quest = Quest:new(xi.questLog.SANDORIA, xi.quest.id.sandoria.HEALING_THE_LAND)

quest.reward =
{
    fameArea = xi.fameArea.SANDORIA,
    item     = xi.item.SCROLL_OF_TELEPORT_HOLLA,
    title    = xi.title.PILGRIM_TO_HOLLA,
    fame     = 30,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.SANDORIA) >= 4 and
                player:getMainLvl() >= 10
        end,

        [xi.zone.NORTHERN_SAN_DORIA] =
        {
            ['Eperdur'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(681)
                end,
            },

            onEventFinish =
            {
                [681] = function(player, csid, option, npc)
                    if option == 0 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.SEAL_OF_BANISHING)
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
                    if player:hasKeyItem(xi.ki.SEAL_OF_BANISHING) then
                        return quest:progressEvent(682)
                    else
                        return quest:progressEvent(683)
                    end
                end,
            },

            onEventFinish =
            {
                [683] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:needToZone(true)
                    end
                end,
            },
        },

        [xi.zone.GUSGEN_MINES] =
        {
            ['qm3'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.SEAL_OF_BANISHING) then
                        player:delKeyItem(xi.ki.SEAL_OF_BANISHING)
                        player:messageSpecial(gusgenID.text.FOUND_LOCATION_SEAL, xi.ki.SEAL_OF_BANISHING)
                    else
                        player:messageSpecial(gusgenID.text.IS_ON_THIS_SEAL, xi.ki.SEAL_OF_BANISHING)
                    end
                end,
            },
        },
    },
}

return quest
