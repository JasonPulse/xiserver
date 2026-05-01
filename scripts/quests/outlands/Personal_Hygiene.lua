-----------------------------------
-- Personal Hygiene
-----------------------------------
-- Log ID: 5, Quest ID: 10
-- Gatih Mijurabi !pos 58.249 -13.086 -49.084 250
-----------------------------------
local kazhamID = zones[xi.zone.KAZHAM]
-----------------------------------

local quest = Quest:new(xi.questLog.OUTLANDS, xi.quest.id.outlands.PERSONAL_HYGIENE)

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getCharVar('BathedInScent') == 1
        end,

        [xi.zone.KAZHAM] =
        {
            ['Gatih_Mijurabi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(191)
                end,
            },

            onEventFinish =
            {
                [191] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.KAZHAM] =
        {
            ['Gatih_Mijurabi'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('BathedInScent') == 1 then
                        return quest:progressEvent(192)
                    else
                        return quest:progressEvent(193)
                    end
                end,
            },

            onEventFinish =
            {
                [193] = function(player, csid, option, npc)
                    if player:getFreeSlotsCount() == 0 then
                        player:messageSpecial(kazhamID.text.ITEM_CANNOT_BE_OBTAINED, xi.item.MITHRAN_STONE)
                        return
                    end

                    if quest:complete(player) then
                        player:addItem(xi.item.MITHRAN_STONE)
                        player:messageSpecial(kazhamID.text.ITEM_OBTAINED, xi.item.MITHRAN_STONE)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.KAZHAM] =
        {
            ['Gatih_Mijurabi'] =
            {
                onTrigger = function(player, npc)
                    if player:getCharVar('BathedInScent') == 1 then
                        return quest:progressEvent(195)
                    else
                        return quest:progressEvent(196)
                    end
                end,
            },
        },
    },
}

return quest
