-----------------------------------
-- Help Not Wanted
-----------------------------------
-- Log ID: 8, Quest ID: 79
-- Ken : Abyssea - Altepa (G-8), entity 17670759
-- !addquest 8 79
-----------------------------------
-- Retail (bg-wiki "Help Not Wanted").
-- |Start=Ken (A) (G-8), Abyssea - Altepa  |Fame=aalt |FLevel=1  |Repeatable=Yes
-- |Item Reqs=Soulgauger SGR-1, Blank Gauger Plates, Gauger Plate
-- |Reward=650 Cruor first time, 250-650 subsequently "depending on picture quality".
--         Chance at an Empyrean +1 HANDS seal.
--   1. "Speak to Ken (A) at (G-8), north of Conflux #4, to begin this quest."
--   2. "Examine each crate behind Ken (A), and obtain the Soulgauger SGR-1 and
--      purchase some Blank Gauger Plates from the other."
--   3. Capture a notorious fiend and bring the plate back.
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Altepa:
--   300 -> "Yes? I'm sorting through these gauger plates, and I certainly don't need
--          your help. Find someone else to bother."                the fame gate
--   296 -> "........." then "Wha...! Don't sneak up on me like that! You almost made
--          me drop this gauger plate."                                THE OFFER
--   298 -> "If you manage to take some prints without impaling yourself on a cactus
--          or something, bring them back to me" plus "If you're actually able to
--          gather some intel on the fiercest fiends, I might actually give you a
--          reward."                                                  the reminder
--   299 -> "Oh, you're back. I was hoping one of the fiends got you. I guess you want
--          me to take a look at this..." and the appraisal branches, including "How
--          charming. Perhaps next you could bring me a picture of a cutesy widdle
--          baby chocobo chick."                                       the turn-in
--   297 -> "You again? Can't you just mind your own business?"       the brush-off
--   301 -> "I may never have graduated from the academy, but I must be strong..."
--                                                                    his idle line
--
-- The capture lives in scripts/globals/abyssea/soulgauger.lua.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HELP_NOT_WANTED)

local handsSeals =
{
    xi.item.LANCERS_SEAL_HANDS,
    xi.item.CIRQUE_SEAL_HANDS,
    xi.item.CHARIS_SEAL_HANDS,
}

-- bg-wiki: 650 flat the first time, then 250-650 "depending on picture quality",
-- which is the four appraisal levels.
local cruorFirst  = 650
local cruorRepeat = { [1] = 250, [2] = 450, [3] = 650 }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

local function payOut(player, firstTime)
    local grade = xi.abyssea.soulgauger.heldGrade(player) or xi.abyssea.soulgauger.grade.BLANK

    xi.abyssea.soulgauger.consumePlate(player)

    if grade == xi.abyssea.soulgauger.grade.BLANK then
        return false
    end

    xi.abyssea.questReward(player, firstTime and cruorFirst or (cruorRepeat[grade] or 0), handsSeals)

    return true
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ALTEPA) >= 1
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Ken'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(296)
                end,
            },

            onEventFinish =
            {
                [296] = function(player, csid, option, npc)
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
            ['Ken'] =
            {
                onTrigger = function(player, npc)
                    if xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(298)
                    end

                    return quest:progressEvent(299, xi.abyssea.soulgauger.heldGrade(player))
                end,
            },

            onEventFinish =
            {
                [299] = function(player, csid, option, npc)
                    if payOut(player, true) then
                        quest:complete(player)
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
            ['Ken'] =
            {
                onTrigger = function(player, npc)
                    if xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(301)
                    end

                    return quest:progressEvent(299, xi.abyssea.soulgauger.heldGrade(player))
                end,
            },

            onEventFinish =
            {
                [299] = function(player, csid, option, npc)
                    payOut(player, false)
                end,
            },
        },
    },
}

return quest
