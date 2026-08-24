-----------------------------------
-- Motherly Love
-----------------------------------
-- Log ID: 8, Quest ID: 82
-- Alisa      : Abyssea - Altepa (C-11), entity 17670745
-- Malene     : Abyssea - Altepa (C-11), entity 17670746
-- Bugul_Noz  : Abyssea - Altepa, popped at qm_bugul_noz 17670600
-- !addquest 8 82
-----------------------------------
-- Retail (bg-wiki "Motherly Love").
-- |Start=Alisa (A) (C-11), Abyssea - Altepa  |Fame=aalt |FLevel=4
-- |Item Reqs=Sabulous Clay, KI Moon pendant  |Reward=700 Cruor
-- |Next=Look to the Sky  |Repeatable= (blank, so once only)
--   1. "Speak to Alisa (C-11), at the outpost near Conflux #8, to begin the quest."
--   2. "Speak to Malene (A) nearby to learn about the monster Bugul Noz."
--   3. "Travel to Conflux #6, and obtain a Sabulous Clay from the Fear Dearg."
--   4. "Spawn Bugul Noz at the ??? in (E-10)."
--   5. "Defeat him and you will obtain the KI Moon pendant."
--   6. "Return and speak to Alisa (A)."
--   7. "Speak to Malene (A) to complete the quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Alisa 265 -> 8115  her idle line, "How curious! Whatever could be keeping those
--          two...?"
--   Alisa 267 -> 8115-8117  THE OFFER. "Have you perhaps seen my dear family? My
--          husband Zacc and daughter Enu, that is..." / "They must have just gone for
--          a little stroll around the camp."
--   Alisa 270 -> 8124-8127  the Moon pendant handed back, and her memory returning:
--          "That's the pendant I gave to Enu! Whyever do you have it?" through
--          "This can't be happening! Oh, please, Goddess have mercy!"
--   Alisa 271 -> 8129  "I am sorry... Please leave me alone with my thoughts."
--   Malene 266 -> 8293/8294  her idle lines.
--   Malene 268 -> 8118-8121  the Bugul Noz briefing. "Everyone knows the poor souls
--          lost their lives to a fiend" / "it was a positively frightening thing they
--          call the Bugul Noz."
--   Malene 269 -> 8123  the reminder, "It was the fearsome Bugul Noz that claimed
--          Zacc and Enu's lives that day."
--   Malene 272 -> 8130-8132  THE COMPLETION. "What's that? You've slain the Bugul
--          Noz, you say?"
--   Malene 273 -> 8132  the tail of that line on its own.
--   Malene 274 -> 8133/8134  her post-completion lines, "I hear that Alisa has her
--          memories back."
--
-- ALISA'S 275/276/278/279 AND MALENE'S 280/281 ARE THE NEXT QUEST, not this one:
-- 8137 "This ${keyitem-singular} belonged to my daughter. I would like for you to
-- take it and bury it as close to the sky as you can" is Look to the Sky, which
-- bg-wiki lists as |Next=. They are deliberately untouched here.
--
-- THE NM POP is not this quest's business. Bugul Noz has its own pop ???
-- (qm_bugul_noz, 17670600, csid 1010) and that is the shared Abyssea pop-item system,
-- the same 191-byte program every qm_* in the zone carries. All this quest does is
-- notice the kill, which is what bg-wiki describes: "Defeat him and you will obtain
-- the KI Moon pendant."
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.MOTHERLY_LOVE)

local cruorReward = 700

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ALTEPA) >= 4
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Alisa'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(267)
                end,
            },

            onEventFinish =
            {
                [267] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Malene'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    -- Alisa has taken the pendant back, so Malene closes the quest.
                    if prog >= 2 then
                        return quest:progressEvent(272)
                    elseif prog == 1 then
                        return quest:event(269)
                    end

                    return quest:progressEvent(268)
                end,
            },

            ['Alisa'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.MOON_PENDANT) then
                        return quest:progressEvent(270, xi.ki.MOON_PENDANT)
                    elseif quest:getVar(player, 'Prog') >= 2 then
                        return quest:event(271)
                    end

                    return quest:event(265)
                end,
            },

            -- "Defeat him and you will obtain the KI Moon pendant."
            ['Bugul_Noz'] =
            {
                onMobDeath = function(mob, player, optParams)
                    if
                        quest:getVar(player, 'Prog') == 1 and
                        not player:hasKeyItem(xi.ki.MOON_PENDANT)
                    then
                        npcUtil.giveKeyItem(player, xi.ki.MOON_PENDANT)
                    end
                end,
            },

            onEventFinish =
            {
                [268] = function(player, csid, option, npc)
                    quest:setVar(player, 'Prog', 1)
                end,

                [270] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.MOON_PENDANT)
                    quest:setVar(player, 'Prog', 2)
                end,

                [272] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                        xi.abyssea.questReward(player, cruorReward, nil)
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
            ['Malene'] = quest:event(274):replaceDefault(),
        },
    },
}

return quest
