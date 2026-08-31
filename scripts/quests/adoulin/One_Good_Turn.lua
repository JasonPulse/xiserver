-----------------------------------
-- One Good Turn...
-----------------------------------
-- Log ID: 9, Quest ID: 28
-- Chelidoine : Eastern Adoulin (J-9), entity 17830126
-- !addquest 9 28
-----------------------------------
-- Retail (bg-wiki "One Good Turn...").
-- |Start=Chelidoine, Eastern Adoulin (J-9)  |Fame=Adoulin  |FLevel=5
-- |Reward=500 EXP, 300 Bayld   Involves a Japanese Midnight wait.
--   1. Talk to Chelidoine, NE of the Coronal Esplanade waypoint.
--   2. Answer six questions, one per coalition.
--   3. Wait for JP midnight and return.
--
-- Not a coalition-engine quest; an earlier pass in this repo recorded it as one.
-- Nothing here touches xi.coalitionAssignments and no imprimaturs change hands.
--
-- The answer indices come off the client. Message 8088 carries the question and all
-- three answer rows in one string, each a Multiple Choice on parameter 0, so the
-- coalition index picks both the topic and which answer sits on each row:
--   row 0  Assist other pioneers / Do not engage in battle while delivering /
--          Gather things yourself / Find a good angle of approach /
--          Attack from the back / Check what the target wants
--   row 1  Attack from specific locations / Using waypoints is acceptable /
--          Buy from the auction house or pioneers / Swiftly destroy ergon loci /
--          Don't forget gathering tools / Stay as far away as possible
--   row 2  Lure enemies away from the area / Walk slowly to avoid dropping /
--          It's acceptable to deliver similar items / Acquire results from
--          someone else / Assist other pioneers / Fight enemies together
-- Lining bg-wiki's six Choose lines up against those rows gives correctAnswer, and
-- all six match. Question 4 is the trap: "Assist other pioneers" is right for
-- Peacekeepers too, but sits on row 2 there rather than row 0.
--
-- Question order is fixed: 8087 names Pioneers first, 8091 names Mummers last, and
-- 8090's own list covers the four between.
--
-- Csids on Chelidoine's block:
--   2540 -> 8079-8096  the quiz; 8082 accepts, 8088 asks, 8094 confirms
--   2543 -> 8097       all six correct
--   2542 -> 8102-8112  partial report; 8103 offers a retake, so it resets
--
-- The six answer indices are proven. THE UPDATE SEQUENCING IS NOT: it follows the
-- stage-counter idiom coalition_assignments.lua uses in this zone, but nobody has
-- watched this tree advance live. One puppet run settles it.
-----------------------------------

local quest = Quest:new(xi.questLog.ADOULIN, xi.quest.id.adoulin.ONE_GOOD_TURN)

local chelidoine = 17830126

-- Indexed by question number, 0 through 5, in the order the client asks them:
-- Pioneers, Couriers, Inventors, Scouts, Peacekeepers, Mummers.
local correctAnswer = { [0] = 0, [1] = 1, [2] = 1, [3] = 0, [4] = 2, [5] = 0 }

local questionCount = 6

local varStage  = 'GoodTurnStage'
local varScore  = 'GoodTurnScore'

local function resetFlow(player)
    player:setLocalVar(varStage, 0)
    player:setLocalVar(varScore, 0)
end

quest.reward =
{
    fameArea = xi.fameArea.ADOULIN,
    bayld    = 300,
    exp      = 500,
}

--- The quiz tree, shared by the first run and every retake.
local function quizUpdate(player, csid, option)
    if csid ~= 2540 then
        return
    end

    local stage = player:getLocalVar(varStage)

    -- Stage 0 is 8082, "Do you have time to explain?" Row 0 agrees.
    if stage == 0 then
        if option ~= 0 then
            resetFlow(player)
            player:updateEvent(0)

            return
        end

        player:setLocalVar(varStage, 1)
        player:updateEvent(0)

        return
    end

    -- Stages 1 to 6 are the six askings of 8088.
    if stage <= questionCount then
        local question = stage - 1

        if option == correctAnswer[question] then
            player:setLocalVar(varScore, player:getLocalVar(varScore) + 1)
        end

        player:setLocalVar(varStage, stage + 1)
        player:updateEvent(question + 1)

        return
    end

    -- Stage 7 is 8094, the confirmation. Row 1 is "Let me reconsider."
    if option ~= 0 then
        resetFlow(player)
    end

    player:updateEvent(0)
end

quest.sections =
{
    -- Section: Chelidoine cannot get the hang of pioneering and wants pointers.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ADOULIN) >= 5
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Chelidoine'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= chelidoine then
                        return
                    end

                    resetFlow(player)

                    return quest:progressEvent(2540)
                end,
            },

            onEventUpdate =
            {
                [2540] = function(player, csid, option, npc)
                    quizUpdate(player, csid, option)
                end,
            },

            onEventFinish =
            {
                [2540] = function(player, csid, option, npc)
                    -- Bailing out at 8082 or 8094 leaves the stage short, and
                    -- retail simply has not started anything yet.
                    if player:getLocalVar(varStage) <= questionCount then
                        resetFlow(player)

                        return
                    end

                    quest:begin(player)
                    quest:setVar(player, 'Score', player:getLocalVar(varScore))
                    quest:setVar(player, 'Wait', NextJstDay())
                    resetFlow(player)
                end,
            },
        },
    },

    -- Section: he goes off and tries it, and tells you how it went the next day.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Wait <= GetSystemTime()
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            ['Chelidoine'] =
            {
                onTrigger = function(player, npc)
                    if npc:getID() ~= chelidoine then
                        return
                    end

                    if quest:getVar(player, 'Score') >= questionCount then
                        return quest:progressEvent(2543)
                    end

                    return quest:progressEvent(2542)
                end,
            },

            onEventFinish =
            {
                -- Every answer landed. 8097, and he is a pioneer at last.
                [2543] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        quest:setVar(player, 'Score', 0)
                        quest:setVar(player, 'Wait', 0)
                    end
                end,

                -- 8112, only a couple of them worked. Hand the quest back so the
                -- quiz can be retaken, which is what 8103 offers.
                [2542] = function(player, csid, option, npc)
                    player:delQuest(xi.questLog.ADOULIN, xi.quest.id.adoulin.ONE_GOOD_TURN)
                    quest:setVar(player, 'Score', 0)
                    quest:setVar(player, 'Wait', 0)
                end,
            },
        },
    },
}

return quest
