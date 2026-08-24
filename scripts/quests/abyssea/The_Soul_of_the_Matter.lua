-----------------------------------
-- The Soul of the Matter
-----------------------------------
-- Log ID: 8, Quest ID: 17
-- Cleades : Abyssea - Konschtat (G-5), entity 16839227
-- !addquest 8 17
-----------------------------------
-- Retail (bg-wiki "The Soul of the Matter").
-- |Start=Cleades (A) (G-5), Abyssea - Konschtat  |Fame=akon |FLevel=1
-- |Previous=Rose on the Heath  |Next=Secret Agent Man  |Repeatable=Yes
-- |Reward=First time 400-520 Cruor and a Behemoth Ring. Subsequently 200-260 Cruor.
--   1. "Speak with Cleades (A) at (G-5)."
--   2. "Next to Cleades (A) are some Lined Boxes which you can obtain your Soulgauger
--      SGR-1 and purchase Gauger Plates."
--   3. "Equip the Soulgauger SGR-1 and Gauger Plates and then look for an NM to get a
--      good quality capture of. Unlike when farming Zeni, you do not need to lower
--      the mob's HP."
--   4. "Return to Cleades (A) and trade your captures to him. He will then appraise
--      your work. There are four appraisal levels."
--   "This quest can only be completed once per Vana'diel day."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Konschtat:
--   269 -> "Yes? I've not seen your face before. I'm afraid we've got our hands full
--          taking care of our own men."                        the fame gate
--   265 -> "So you're the one Captain Helga spoke of." through "This is the prized
--          tool of our trade: a pretty little thing we call the Soulgauger SGR-1."
--                                                                       THE OFFER
--   266 -> "Ho there! How go your recon efforts? If you've got any soulprints for us,
--          just hand them over." plus "you'll find a spare Soulgauger SGR-1 and blank
--          gauger plates in that casket over there"                   the reminder
--   267 -> the appraisal, first time. It carries every branch: "These soulstrands are
--          too faint", "Sorry, but we'll be needing another sample", and the reward.
--   268 -> the same appraisal on a repeat run.
--   294 -> "I'm afraid that we're still in the process of analyzing the last print
--          you brought us. Come back in a bit."                the daily cooldown
--
-- The capture itself lives in scripts/globals/abyssea/soulgauger.lua, which also
-- documents why the plate's grade is held in char vars rather than in the item.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_SOUL_OF_THE_MATTER)

local dailyVar = 'Soulgauger_Konschtat_Day'

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_KONSCHTAT,
}

local function doneToday(player)
    return player:getCharVar(dailyVar) >= VanadielUniqueDay()
end

--- bg-wiki gives a band per appraisal level and four levels, so the grade picks the
--- band. A blank plate is rejected outright and the run is not consumed.
local cruorFirst  = { [1] = 400, [2] = 460, [3] = 520 }
local cruorRepeat = { [1] = 200, [2] = 230, [3] = 260 }

local function appraisalGrade(player)
    return xi.abyssea.soulgauger.heldGrade(player) or xi.abyssea.soulgauger.grade.BLANK
end

local function payOut(player, byGrade, firstTime)
    local grade = appraisalGrade(player)

    xi.abyssea.soulgauger.consumePlate(player)

    if grade == xi.abyssea.soulgauger.grade.BLANK then
        -- "Why, this plate's completely blank!" No reward, no daily burn.
        return
    end

    xi.abyssea.questReward(player, byGrade[grade] or 0, nil)

    if firstTime then
        npcUtil.giveItem(player, xi.item.BEHEMOTH_RING)
    end

    player:setCharVar(dailyVar, VanadielUniqueDay())
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_KONSCHTAT) >= 1
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Cleades'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(265)
                end,
            },

            onEventFinish =
            {
                [265] = function(player, csid, option, npc)
                    quest:begin(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Cleades'] =
            {
                onTrigger = function(player, npc)
                    if xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(266)
                    end

                    return quest:progressEvent(267, appraisalGrade(player))
                end,
            },

            onEventFinish =
            {
                [267] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        payOut(player, cruorFirst, true)
                    end
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Cleades'] =
            {
                onTrigger = function(player, npc)
                    if doneToday(player) then
                        return quest:event(294)
                    elseif xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(266)
                    end

                    return quest:progressEvent(268, appraisalGrade(player))
                end,
            },

            onEventFinish =
            {
                [268] = function(player, csid, option, npc)
                    payOut(player, cruorRepeat, false)
                end,
            },
        },
    },
}

return quest
