-----------------------------------
-- Slacking Subordinates
-----------------------------------
-- Log ID: 8, Quest ID: 81
-- Chumimi      : Abyssea - Altepa (G-7), entity 17670751
-- Chemioue     : Abyssea - Altepa (G-7), entity 17670756
-- Tapoh Lihzeh : Abyssea - Altepa (G-6/G-7), entity 17670757
-- Biggorf      : Abyssea - Altepa (G-7), entity 17670758
-- !addquest 8 81
-----------------------------------
-- Retail (bg-wiki "Slacking Subordinates").
-- |Start=Chumimi (A) (G-7), Abyssea - Altepa  |Fame=aalt |FLevel=1
-- |Previous=The Titus Touch  |Repeatable=Yes
-- |Reward=400-500 Cruor first time, 150-250 subsequently. Chance at an Empyrean +1
--         BODY seal, "ONLY if you do well with the quest".
--   "You must zone after completing The Titus Touch before you can start this quest."
--   1. "You must talk to all 3 of the following NPCs: Biggorf, Chemioue, Tapoh
--      Lihzeh."
--   2. "Each NPC will give you two facts about a fiend. You must then report them to
--      Chumimi (A)."
--   3. "Two will give the same piece of information (correct answer) while the third
--      will say something different (wrong answer)."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Altepa:
--   316 -> "Oh, it's you again! Thank heavens! I'm in a painfully problematic
--          pickle-wickle right now" / "It's my slacking assistantarus!"  THE OFFER
--   317 -> "Were you able to gather-wather any findings from my assistantarus?
--          Chemioue, Biggorf, and Tapoh Lihzeh"                       the reminder
--   318 -> "Well, did my good-for-nothing assistants have their reports ready for
--          you?" then "Share with me what you've heard"           the report event
--   319 -> "I truly cannot thank you enough."           the post-completion line
--   350 -> THE OUTCOME, and it is graded on parameter 0. Message 8111 reads "The
--          information you've provided [seems a bit sketchy, but / seems reasonable
--          enough. / corroborates with my own research perfectly!]", so 0, 1 and 2
--          are the three verdicts and only 2 is "doing well".
--   313 and 315 belong to The Titus Touch, not this quest.
-- The three assistants each carry a report and an idle line:
--   Chemioue 320 report / 323 idle, Tapoh Lihzeh 321 / 324, Biggorf 322 / 325.
--
-- THE REPORT PARAMETERS WERE MAPPED EMPIRICALLY on the puppet, by firing csid 320
-- with different parameters and reading the rendered line back:
--   parameter 0  the symptom   0 chest pains, 1 dizziness, 2 headaches,
--                              3 ringing in the ears        ("1" gave "dizziness")
--   parameter 1  the category  0 colour, 1 shape, 2 habitat
--   parameter 2  the value within that category, 0-3
-- Confirmed pairs: "0 0 2" rendered "a dreadfully garish hue", "0 0 3" rendered
-- "glistening black", "0 1 1" rendered "a rather rotund critter", "0 2 1" rendered
-- "came from the water". Those line up exactly with the answer menus, which is what
-- makes the grading trustworthy:
--   8100 category  0 colour / 1 shape / 2 habitat
--   8101 colour    0 Extravagant / 1 Nondescript / 2 Garish / 3 Black and glistening
--   8102 shape     0 Pointy jagged horns / 1 Squat rotund body / 2 Angular bony legs
--                  / 3 Flat sturdy jaw
--   8103 habitat   0 High elevations / 1 Near water / 2 Shadowy crags / 3 Beneath
--                  the sands
--   8105 symptoms  0 Chest pains / 1 Dizziness / 2 Headaches / 3 Ringing in the ears
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SLACKING_SUBORDINATES)

local assistants =
{
    ['Chemioue']     = { slot = 1, report = 320, idle = 323 },
    ['Tapoh_Lihzeh'] = { slot = 2, report = 321, idle = 324 },
    ['Biggorf']      = { slot = 3, report = 322, idle = 325 },
}

local categoryCount = 3
local valueCount    = 4
local symptomCount  = 4

local gradeSketchy    = 0
local gradeReasonable = 1
local gradePerfect    = 2

local bodySeals =
{
    xi.item.MAVI_SEAL_BODY,
    xi.item.ESTOQUEURS_SEAL_BODY,
    xi.item.SYLVAN_SEAL_BODY,
    xi.item.CIRQUE_SEAL_BODY,
    xi.item.RAVAGERS_SEAL_BODY,
}

local cruorPerfectFirst  = 500
local cruorPerfectRepeat = 250
local cruorPoor          = 200

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ALTEPA,
}

--- Roll the fiend, then decide which assistant is the odd one out. Two report the
--- truth and one reports a different value in the SAME category, which is what makes
--- the majority readable.
local function rollFiend(player)
    local category = math.random(0, categoryCount - 1)
    local value    = math.random(0, valueCount - 1)
    local symptom  = math.random(0, symptomCount - 1)
    local liar     = math.random(1, 3)

    -- A wrong value has to differ, so it is rolled as an offset rather than a retry.
    local wrongValue = (value + math.random(1, valueCount - 1)) % valueCount

    quest:setVar(player, 'Category', category)
    quest:setVar(player, 'Value', value)
    quest:setVar(player, 'Symptom', symptom)
    quest:setVar(player, 'Liar', liar)
    quest:setVar(player, 'WrongValue', wrongValue)
    quest:setVar(player, 'Heard', 0)
    quest:setVar(player, 'PickCategory', 0)
    quest:setVar(player, 'PickValue', 0)
    quest:setVar(player, 'PickSymptom', 0)
    quest:setVar(player, 'Grade', -1)
end

local function heardAll(player)
    return bit.band(quest:getVar(player, 'Heard'), 7) == 7
end

--- What one assistant says: everyone agrees on the symptom, the liar differs on the
--- descriptor value only.
local function reportFor(player, slot)
    local value = quest:getVar(player, 'Value')

    if quest:getVar(player, 'Liar') == slot then
        value = quest:getVar(player, 'WrongValue')
    end

    return quest:getVar(player, 'Symptom'), quest:getVar(player, 'Category'), value
end

local function assistantActions(name)
    local assistant = assistants[name]

    return
    {
        onTrigger = function(player, npc)
            if not heardAll(player) or quest:getVar(player, 'Grade') == -1 then
                quest:setVar(player, 'Heard',
                    bit.bor(quest:getVar(player, 'Heard'), bit.lshift(1, assistant.slot - 1)))

                return quest:progressEvent(assistant.report, reportFor(player, assistant.slot))
            end

            return quest:event(assistant.idle)
        end,
    }
end

--- Both facts right is "doing well" and the only path to a seal.
local function gradeAnswer(player)
    local descriptorRight = quest:getVar(player, 'PickCategory') == quest:getVar(player, 'Category') and
        quest:getVar(player, 'PickValue') == quest:getVar(player, 'Value')
    local symptomRight = quest:getVar(player, 'PickSymptom') == quest:getVar(player, 'Symptom')

    if descriptorRight and symptomRight then
        return gradePerfect
    elseif descriptorRight or symptomRight then
        return gradeReasonable
    end

    return gradeSketchy
end

--- 318 walks three sub-menus in turn, so the picks are recorded as they arrive. The
--- order the client asks in is category, then the value, then the symptom.
local reportUpdate = function(player, csid, option, npc)
    local step = quest:getVar(player, 'ReportStep')

    if step == 0 then
        quest:setVar(player, 'PickCategory', option)
    elseif step == 1 then
        quest:setVar(player, 'PickValue', option)
    else
        quest:setVar(player, 'PickSymptom', option)
    end

    quest:setVar(player, 'ReportStep', step + 1)
    player:updateEvent(quest:getVar(player, 'PickCategory'), quest:getVar(player, 'PickValue'))
end

local reportFinish = function(player, csid, option, npc)
    quest:setVar(player, 'Grade', gradeAnswer(player))
    quest:setVar(player, 'ReportStep', 0)
end

local function payOut(player, perfectCruor)
    local grade = quest:getVar(player, 'Grade')

    if grade == gradePerfect then
        xi.abyssea.questReward(player, perfectCruor, bodySeals)
    else
        -- "ONLY if you do well with the quest", so a poor report earns no seal.
        xi.abyssea.questReward(player, cruorPoor, nil)
    end

    rollFiend(player)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SLACKING_SUBORDINATES)
end

local function altepaZone(chumimiTrigger, finishes)
    local zone =
    {
        ['Chumimi'] = { onTrigger = chumimiTrigger },

        onEventUpdate =
        {
            [318] = reportUpdate,
        },
    }

    finishes[318] = reportFinish
    zone.onEventFinish = finishes

    for name, _ in pairs(assistants) do
        zone[name] = assistantActions(name)
    end

    return zone
end

local function acceptedTrigger(player, npc)
    if quest:getVar(player, 'Grade') >= 0 then
        return quest:progressEvent(350, quest:getVar(player, 'Grade'))
    elseif not heardAll(player) then
        return quest:event(317)
    end

    return quest:progressEvent(318)
end

local function repeatTrigger(player, npc)
    if quest:getVar(player, 'Grade') >= 0 then
        return quest:progressEvent(350, quest:getVar(player, 'Grade'))
    elseif heardAll(player) then
        return quest:progressEvent(318)
    elseif quest:getMustZone(player) then
        return quest:event(319)
    end

    return quest:progressEvent(316)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.THE_TITUS_TOUCH) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.ABYSSEA_ALTEPA) >= 1
        end,

        [xi.zone.ABYSSEA_ALTEPA] =
        {
            ['Chumimi'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(316)
                end,
            },

            onEventFinish =
            {
                [316] = function(player, csid, option, npc)
                    quest:begin(player)
                    rollFiend(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ALTEPA] = altepaZone(acceptedTrigger,
        {
            [350] = function(player, csid, option, npc)
                if quest:complete(player) then
                    payOut(player, cruorPerfectFirst)
                end
            end,
        }),
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ALTEPA] = altepaZone(repeatTrigger,
        {
            [316] = function(player, csid, option, npc)
                rollFiend(player)
            end,

            [350] = function(player, csid, option, npc)
                payOut(player, cruorPerfectRepeat)
            end,
        }),
    },
}

return quest
