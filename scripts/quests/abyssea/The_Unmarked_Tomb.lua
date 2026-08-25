-----------------------------------
-- The Unmarked Tomb
-----------------------------------
-- Log ID: 8, Quest ID: 84
-- Oiheaurese : Abyssea - Altepa (G-7), entity 17670752
-- Yachemidot : Abyssea - Altepa (J-9), entity 17670754
-- qm1        : Meriphataud Mountains (K-8), entity 17265243
-- !addquest 8 84
-----------------------------------
-- Retail (bg-wiki "The Unmarked Tomb").
-- |Start=Oiheaurese (A) (G-7), Abyssea - Altepa  |Fame=aalt |FLevel=6
-- |Item Reqs=KI Wyvern egg, KI Wyvern egg shell
-- |Reward=KI Emerald abyssite of lenity, 1,200 Cruor  |Repeatable= (blank)
--   1. "Talk to Oiheaurese at (G-7), near Conflux 7 at the Oasis of Revelation Rock,
--      who asks for a KI Wyvern egg."
--   2. "Speak with Yachemidot (A) at (J-9). You will receive a KI Wyvern egg."
--   3. "Travel to Meriphataud Mountains and head to (K-8), along the eastern edge of
--      the Spine. Interact with the ??? to obtain the KI Wyvern egg shell."
--   4. "Return to Yachemidot at (J-9) to receive the KI Emerald abyssite of lenity."
--   5. "Finally, talk to Oiheaurese at (G-7) to complete the quest."
--
-- CSIDS DECODED, NOT GUESSED. Per-csid attribution from each entity's byte ranges:
--   Oiheaurese 282 -> 8163/8164  his idle line, "Curses! Curse it all!"
--   Oiheaurese 285 -> 8165-8167  THE OFFER. "I am a researcher of wyverns, and one
--          of no small repute."
--   Oiheaurese 286 -> 8169       the reminder, "I am a mere academic, hardly suited
--          for traipsing across this wasteland on a wild ${keyitem-singular} chase."
--   Oiheaurese 287 -> 8182-8184  after Yachemidot hands the egg over: "The tales say
--          that the ${keyitem-singular: 0[2]} will hatch if laid to rest on
--          Drogaroga's Spine in the Meriphataud Mountains."
--   Oiheaurese 288 -> 8183/8184  the same directions as a reminder.
--   Oiheaurese 289 -> 8185/8186  THE TURN-IN. "So the ${keyitem-singular: 1[2]} has
--          already hatched" -- it names BOTH key items, index 0 and index 1, which is
--          why the egg and the shell are both passed as params.
--   Oiheaurese 290 -> 8189       his post-completion line.
--   Yachemidot 284 -> 8176       "..." , his idle.
--   Yachemidot 291 -> 8171-8173  he hands the egg over: "The ${keyitem-singular: 0[2]}
--          you seek is indeed here. But I fear it will not be hatching now...nor
--          ever."
--   Yachemidot 292 -> 8178       the reminder, "That ${keyitem-singular: 0[2]} must be
--          returned to its rightful home."
--   Yachemidot 293 -> 8179-8181  he gives the abyssite: "Take this. I have need for it
--          no more."
--
-- THE MERIPHATAUD ??? HAS NO CUTSCENE FOR THIS QUEST. qm1 (17265243) owns csid 33,
-- but 33 decodes to the Cyranuce dragoon storyline (8273-8290, "Behold! A dragon,
-- after all this time...", Rahal Dragonslayer, the oubliette) and belongs to that
-- quest, not this one. Its only other block, 56, is 31 bytes with no message table
-- of its own. So the shell is picked up as a plain key-item grant, the same shape the
-- event-less Supply Points in Attohwa use, rather than firing a cutscene that would
-- play the wrong story.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_UNMARKED_TOMB)

local meriphataudTombQm = 17265243

local cruorReward = 1200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ALTEPA) >= 6
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Oiheaurese'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(285)
                end,
            },

            onEventFinish =
            {
                [285] = function(player, csid, option, npc)
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
            ['Yachemidot'] =
            {
                onTrigger = function(player, npc)
                    if player:hasKeyItem(xi.ki.WYVERN_EGG_SHELL) then
                        return quest:progressEvent(293, xi.ki.WYVERN_EGG_SHELL)
                    elseif player:hasKeyItem(xi.ki.WYVERN_EGG) then
                        return quest:event(292, xi.ki.WYVERN_EGG)
                    elseif quest:getVar(player, 'Prog') >= 2 then
                        return quest:event(284)
                    end

                    return quest:progressEvent(291, xi.ki.WYVERN_EGG)
                end,
            },

            ['Oiheaurese'] =
            {
                onTrigger = function(player, npc)
                    local prog = quest:getVar(player, 'Prog')

                    if prog >= 2 then
                        return quest:progressEvent(289, xi.ki.WYVERN_EGG, xi.ki.WYVERN_EGG_SHELL)
                    elseif prog == 1 then
                        return quest:event(288, xi.ki.WYVERN_EGG)
                    end

                    return quest:event(286, xi.ki.WYVERN_EGG)
                end,
            },

            onEventFinish =
            {
                [291] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.ki.WYVERN_EGG)
                    quest:setVar(player, 'Prog', 1)
                end,

                [293] = function(player, csid, option, npc)
                    player:delKeyItem(xi.ki.WYVERN_EGG_SHELL)
                    npcUtil.giveKeyItem(player, xi.ki.EMERALD_ABYSSITE_OF_LENITY)
                    quest:setVar(player, 'Prog', 2)
                end,

                [289] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Prog', 0)
                        xi.abyssea.questReward(player, cruorReward, nil)
                    end
                end,
            },
        },

        [xi.zone.MERIPHATAUD_MOUNTAINS] =
        {
            ['qm1'] =
            {
                onTrigger = function(player, npc)
                    if
                        npc:getID() ~= meriphataudTombQm or
                        not player:hasKeyItem(xi.ki.WYVERN_EGG)
                    then
                        return
                    end

                    player:delKeyItem(xi.ki.WYVERN_EGG)
                    npcUtil.giveKeyItem(player, xi.ki.WYVERN_EGG_SHELL)

                    return quest:noAction()
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
            ['Oiheaurese'] = quest:event(290):replaceDefault(),
        },
    },
}

return quest
