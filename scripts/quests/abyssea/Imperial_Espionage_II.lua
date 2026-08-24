-----------------------------------
-- Imperial Espionage II
-----------------------------------
-- Log ID: 8, Quest ID: 71
-- Tyamah : Abyssea - Uleguerand (F-7), entity 17814102
-- !addquest 8 71
-----------------------------------
-- Retail (bg-wiki "Imperial Espionage II").
-- |Start=Tyamah (A) (F-7), Abyssea - Uleguerand  |Fame=aule |FLevel=3
-- |Previous=Imperial Espionage  |Repeatable= (blank, so once only)
-- |Reward=1,800 Cruor and KI Vermillion abyssite of avarice
--   1. "Talk to Tyamah (A) at (F-7) Conflux #7 to begin this quest."
--   2. "He asks you to take pictures of 'abnormal, unnatural Abyssean fiends'."
--   3. "Retrieve the Soulgauger SGR-1 and purchase 12x Blank Gauger Plates from the
--      chests next to him."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Uleguerand.
-- Note his csids cover BOTH Imperial Espionage quests, so the split matters:
--   288 -> "(I could tell you what I'm doing here, but then I'd have to kill you.)"
--                                                                     the fame gate
--   289, 290, 295 -> the offer, brief and turn-in of Imperial Espionage, the FIRST
--          quest. Not this one.
--   297 -> "You...! What was your name again!?" then "I have a task for you...for
--          anyone! I need gauger plates...gauger plates of the most abnormal,
--          unnatural Abyssean fiends!"                                 THE OFFER
--   298 -> "Strange blobs suspended in midair! Snails that swim in the sky instead of
--          the water! And more...yes, more..."                        the reminder
--   299 -> "No, this is not one of the creatures that speaks to me in my dreams. It
--          is far too...ordinary."                          the rejected capture
--   300 -> "Yes, these are unmistakably the fiends that I was looking for..." then
--          "In any event, take this."                                  the turn-in
--   301 -> "The deeds you have performed for me today will not go forgotten."
--                                                          the post-completion line
--
-- HE WANTS THE ODD ONES, and 299 exists precisely to reject an ordinary capture, so
-- an unremarkable plate is turned away rather than accepted. The Soulgauger only ever
-- captures notorious fiends (see soulgauger.lua's onItemCheck), so the discriminator
-- here is picture quality: a poor plate reads as "far too ordinary".
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.IMPERIAL_ESPIONAGE_II)

local cruorReward = 1800

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
    keyItem  = xi.ki.VERMILLION_ABYSSITE_OF_AVARICE,
}

local function plateIsStrange(player)
    local grade = xi.abyssea.soulgauger.heldGrade(player)

    return grade ~= nil and grade >= xi.abyssea.soulgauger.grade.FAIR
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.IMPERIAL_ESPIONAGE) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 3
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Tyamah'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(297)
                end,
            },

            onEventFinish =
            {
                [297] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Tyamah'] =
            {
                onTrigger = function(player, npc)
                    if xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(298)
                    elseif not plateIsStrange(player) then
                        return quest:progressEvent(299)
                    end

                    return quest:progressEvent(300)
                end,
            },

            onEventFinish =
            {
                [299] = function(player, csid, option, npc)
                    -- Too ordinary. He keeps nothing and the hunt continues.
                    xi.abyssea.soulgauger.consumePlate(player)
                end,

                [300] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        xi.abyssea.soulgauger.consumePlate(player)
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

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Tyamah'] = quest:event(301):replaceDefault(),
        },
    },
}

return quest
