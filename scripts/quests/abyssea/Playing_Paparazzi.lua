-----------------------------------
-- Playing Paparazzi
-----------------------------------
-- Log ID: 8, Quest ID: 19
-- Naji : Abyssea - Konschtat (J-5), entity 16839228
-- !addquest 8 19
-----------------------------------
-- Retail (bg-wiki "Playing Paparazzi").
-- |Start=Naji (A) (J-5), Abyssea - Konschtat  |Fame=akon |FLevel=6
-- |Previous=Secret Agent Man  |Repeatable=Yes
-- |Item Reqs=KI Naji's linkpearl, Soulgauger SGR-1, Gauger Plate
-- |Reward=First time KI Azure abyssite of merit. Subsequently a Black Mantle.
--   1. "Speak to Naji (A) at (J-5), southeast of Veridical Conflux #08 to begin."
--      "You will hand over the KI Naji's linkpearl obtained at the end of the last
--       quest."
--   2. "You must procure a Gauger Plate of one of the NMs in Abyssea - Konschtat."
--      "Your image should be taken at close range, and facing the NM to qualify."
--      "You do not need to have claim on the monster."
--   3. "Return to Naji (A) and trade one of your acceptable Gauger Plates."
--   "This quest can only be completed once per Vana'diel day."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Konschtat:
--   274 -> "(You there! Yeah, you! Think you could be any more blunderingly
--          obvious?)"                                              the fame gate
--   275 -> the first meeting, where he hands over the plate for Helga. That belongs
--          to the PREVIOUS quest in the chain, not this one.
--   277 -> "(Shhh! You're making more noise than a bevy of bugards!)" then "You hand
--          over Naji's linkpearl." and "word has it that you've got some skill with a
--          Soulgauger SGR-1"                                          THE OFFER
--   278 -> "That was quick, rookie. Well, what have you got for me?" plus the brief
--          about the most imposing threats                            the reminder
--   279 -> the appraisal, first time, carrying every branch including "my dear
--          departed grandma coulda got me intel on a piddling peon like this".
--   280 -> the same appraisal on a repeat run.
--
-- HE DEMANDS A BETTER PICTURE THAN CLEADES DOES. bg-wiki: "Your image should be taken
-- at close range, and facing the NM to qualify", where The Soul of the Matter accepts
-- any of the four appraisal levels. So this one requires the top grade.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.PLAYING_PAPARAZZI)

local dailyVar = 'Soulgauger_Paparazzi_Day'

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_KONSCHTAT,
}

local function doneToday(player)
    return player:getCharVar(dailyVar) >= VanadielUniqueDay()
end

local function payOut(player, firstTime)
    local grade = xi.abyssea.soulgauger.heldGrade(player) or xi.abyssea.soulgauger.grade.BLANK

    xi.abyssea.soulgauger.consumePlate(player)

    -- Anything short of a close, face-on shot earns the brush-off and no reward.
    if grade < xi.abyssea.soulgauger.grade.EXCELLENT then
        return false
    end

    if firstTime then
        npcUtil.giveKeyItem(player, xi.ki.AZURE_ABYSSITE_OF_MERIT)
    else
        npcUtil.giveItem(player, xi.item.BLACK_MANTLE)
    end

    player:setCharVar(dailyVar, VanadielUniqueDay())

    return true
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SECRET_AGENT_MAN) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.ABYSSEA_KONSCHTAT) >= 6
        end,

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(277)
                end,
            },

            onEventFinish =
            {
                [277] = function(player, csid, option, npc)
                    quest:begin(player)
                    -- "You hand over Naji's linkpearl."
                    player:delKeyItem(xi.ki.NAJIS_LINKPEARL)
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
            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    if xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(278)
                    end

                    return quest:progressEvent(279, xi.abyssea.soulgauger.heldGrade(player))
                end,
            },

            onEventFinish =
            {
                [279] = function(player, csid, option, npc)
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

        [xi.zone.ABYSSEA_KONSCHTAT] =
        {
            ['Naji'] =
            {
                onTrigger = function(player, npc)
                    if doneToday(player) or xi.abyssea.soulgauger.heldGrade(player) == nil then
                        return quest:event(278)
                    end

                    return quest:progressEvent(280, xi.abyssea.soulgauger.heldGrade(player))
                end,
            },

            onEventFinish =
            {
                [280] = function(player, csid, option, npc)
                    payOut(player, false)
                end,
            },
        },
    },
}

return quest
