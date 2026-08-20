-----------------------------------
-- An Eye for Revenge
-----------------------------------
-- !addquest 8 3
-- Curilla : !pos: -467.7 -3.5 -769.5 132
-----------------------------------
local ID = zones[xi.zone.ABYSSEA_LA_THEINE]
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.AN_EYE_FOR_REVENGE)

quest.reward = {
    keyItem     = xi.ki.SCARLET_ABYSSITE_OF_FURTHERANCE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
            player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOST_MEMORIES) ~= xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Curilla'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(189)
                end,
            },
        },
    },

    {
        -- bg-wiki: "Speak to Curilla (A) at (E-3) while in possession of the
        -- Vial of lambent potion (Obtained from the previous quest)", with
        -- |FLevel=5 against |Fame=alth (Abyssea - La Theine). Neither the key
        -- item nor the fame level was checked.
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
            player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOST_MEMORIES) == xi.questStatus.QUEST_COMPLETED and
            player:hasKeyItem(xi.ki.VIAL_OF_LAMBENT_POTION) and
            player:getFameLevel(xi.fameArea.ABYSSEA_LATHEINE) >= 5
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Curilla'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(190)
                end,
            },

            onEventFinish =
            {
                [190] = function(player, csid, option, npc)
                    -- The potion was deleted in onTrigger, i.e. before the
                    -- cutscene resolved, while quest:begin only runs here --
                    -- so cancelling the cutscene consumed the key item and
                    -- left the quest unstartable. Both now happen together.
                    player:delKeyItem(xi.ki.VIAL_OF_LAMBENT_POTION)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Curilla'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.ki.LUGARHOOS_EYEBALL) then
                        return quest:event(191)
                    else
                        return quest:event(192)
                    end
                end,
            },

            ['Lugarhoo'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if not player:hasKeyItem(xi.ki.LUGARHOOS_EYEBALL) then
                        player:addKeyItem(xi.ki.LUGARHOOS_EYEBALL)
                        player:messageSpecial(ID.text.KEYITEM_OBTAINED, xi.ki.LUGARHOOS_EYEBALL)
                    end
                end,
            },

            onEventFinish =
            {
                [192] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.LUGARHOOS_EYEBALL)
                    player:addCurrency('cruor', 800)
                    player:messageSpecial(ID.text.CRUOR_TOTAL, 800, player:getCurrency('cruor'))
                    quest:complete(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_LA_THEINE] =
        {
            ['Curilla'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(193)
                end,
            },
        },
    },
}

return quest
