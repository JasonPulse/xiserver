-----------------------------------
-- Look to the Sky
-----------------------------------
-- Log ID: 8, Quest ID: 83
-- Alisa : Abyssea - Altepa (C-11), entity 17670745
-- qm    : Abyssea - Altepa (D-11), entity 17670747
-- !addquest 8 83
-----------------------------------
-- bg-wiki: |Start=Alisa (A) (C-11)  |Previous=Motherly Love
-- |Item Reqs=Moon pendant  |Reward=Emerald abyssite of expertise
--   "You must zone after completing Motherly Love in order to start."
--   She returns the Moon pendant to bury "as close to the sky as you can";
--   interact with the ??? at (D-11) on the concrete slab, then again.
--
-- CSIDS (csidmsg.load; Alisa confirmed by resolve_npc.py -- KI 1761 sits at
-- data[13] of her block, and at data[1] of the qm's):
--   Alisa 275 -> 8135-8140  THE OFFER. 8137 "This ${keyitem-singular: 0[2]}
--          belonged to my daughter. I would like for you to take it and bury it
--          as close to the sky as you can." 8138 names Enu.
--   Alisa 276 -> 8140/8141  the reminder.
--   Alisa 278 -> 8154-8158  THE TURN-IN. 8154 "You found a place close to the
--          sky for Enu's ${keyitem-singular: 0[2]}?", 8155 "You met them!?"
--   Alisa 279 -> 8159       post-completion.
--   qm    277 -> 8142-8153  THE BURIAL SCENE, the whole family reunion: 8142
--          "Daddy! Oh, Daddy! Look what I found!", 8143 "My ${keyitem-singular:
--          1[2]}!" -- so the pendant is param 1 for the qm and param 0 for Alisa.
--   Her 267/270/271 belong to Motherly Love and are untouched here.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.LOOK_TO_THE_SKY)

quest.reward =
{
    keyItem = xi.ki.EMERALD_ABYSSITE_OF_EXPERTISE,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:hasCompletedQuest(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MOTHERLY_LOVE) and
                quest:getMustZone(player)
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Alisa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(275, { [0] = xi.ki.MOON_PENDANT })
                end,
            },

            onEventFinish =
            {
                [275] = function(player, csid, option, npc)
                    quest:begin(player)
                    npcUtil.giveKeyItem(player, xi.ki.MOON_PENDANT)
                end,
            },
        },
    },

    -- Pendant in hand: bury it at the slab.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Buried == 0
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['qm'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= 17670747 or not player:hasKeyItem(xi.ki.MOON_PENDANT) then
                        return
                    end

                    return quest:progressEvent(277, { [1] = xi.ki.MOON_PENDANT })
                end,
            },

            ['Alisa'] =
            {
                onTrigger = function(player, npc)
                    return quest:event(276, { [0] = xi.ki.MOON_PENDANT })
                end,
            },

            onEventFinish =
            {
                [277] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.MOON_PENDANT)
                    quest:setVar(player, 'Buried', 1)
                end,
            },
        },
    },

    -- Buried: report back to Alisa.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Buried == 1
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Alisa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(278, { [0] = xi.ki.MOON_PENDANT })
                end,
            },

            onEventFinish =
            {
                [278] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Buried', 0)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Alisa'] = quest:event(279):replaceDefault(),
        },
    },
}

return quest
