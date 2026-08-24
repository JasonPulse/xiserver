-----------------------------------
-- Slip Slidin' Away
-----------------------------------
-- Log ID: 8, Quest ID: 76
-- Michilca           : Abyssea - Uleguerand, entity 17814158
-- Nachou             : Abyssea - Uleguerand, entity 17814159  (southern slope)
-- Perfaumand         : Abyssea - Uleguerand, entity 17814160  (western slope)
-- Resistance Fighter : Abyssea - Uleguerand, entities 17814161 .. 17814166
-- !addquest 8 76
-----------------------------------
-- Retail (bg-wiki "Slip Slidin' Away").
-- |Start=Michilca (A), Abyssea - Uleguerand  |Fame=aule |FLevel=2  |Repeatable=Yes
-- |Reward=Resilient Mantle (augmented). Chance at an Empyrean +1 HANDS seal.
--   1. "Michilca (A) is at the base camp. Talk to her to begin."
--   2. "Stationed at the southern and western slopes you will find two of my men,
--      Nachou and Perfaumand." Which slope you assist with is the player's choice.
--   3. Guide the sliding men back on course.
--   4. "Report to Michilca (A) to complete this quest."
--   "Zoning is required in order to repeat this quest."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Uleguerand.
-- Michilca:
--   408 -> "'Twould appear that precision sliding on sheer-faced cliffs of solid ice
--          is not such an easy task, after all..."                     the gate
--   409 -> "Are you perchance familiar with Thousandfall Ridge?" through "Which slope
--          you assist with is a choice I leave entirely to you."      THE OFFER
--   410 -> the same instructions again                              the reminder
--   411 -> "I see. 'Tis unfortunate, but not entirely unexpected. My men are making
--          the long trek back up the mountain as we speak."        the failed report
--   412 -> "I see. This may not be much, but please accept it as a token of our
--          gratitude."                                            the success report
--   413 -> "I intend to send another unit into the breach before long."
--                                                          the post-completion line
--   414 -> "Ah, a familiar face. We are in need of your assistance in sending another
--          unit into Thousandfall Ridge."                          the repeat offer
-- The two scouts carry the same four programs apiece, Nachou 415-418 and Perfaumand
-- 419-422, which is why they are addressed through one table below:
--   415 / 419 -> "You're quite the accomplished mountaineer to make it this far."
--   416 / 420 -> THE BRIEFING, and it is the authority for the numbers this quest
--                uses: "When I give the signal, TEN of our men will come sliding in
--                this direction. Should any of them veer off course, you are to
--                extend a helping hand and guide them back in the proper direction."
--   417 / 421 -> "Fair work, <pc>. ${number} men missed their target" then "I will
--                pass along word of your success to Michilca."          success,
--                and the miss count is a numeric parameter it renders
--   418 / 422 -> "This will not do at all. With such a small regiment, we will be the
--                easiest of pickings" then "report the failure of the operation to
--                Michilca."                                             failure
--
-- THE CLIENT OVERRULES BG-WIKI ON THE NUMBERS. bg-wiki describes "3 waves of 2-3
-- NPCs", but the briefing the client actually renders says ten men, and the success
-- line takes a miss count. Ten is used here because it comes from the game data.
--
-- WHAT IS OURS RATHER THAN RETAIL: the pass mark and the window. Retail's difficulty
-- comes from sliding down an ice face and physically intercepting strays, which is
-- positional and client-side; the server only ever sees the interactions. So a run is
-- given a time window and a miss allowance, in the same spirit as the martello
-- regeneration rate. Both are single constants below.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.SLIP_SLIDIN_AWAY)

-- Straight from briefing 416/420: "ten of our men will come sliding".
local slidingMen = 10

-- Ours, not retail's. See the header.
local runSeconds   = 90
local missAllowance = 2

local handsSeals =
{
    xi.item.AOIDOS_SEAL_HANDS,
    xi.item.ESTOQUEURS_SEAL_HANDS,
    xi.item.RAIDERS_SEAL_HANDS,
    xi.item.SAVANTS_SEAL_HANDS,
}

-- Nachou runs the southern slope and Perfaumand the western one. Their programs are
-- identical apart from the numbers, so the scout is looked up rather than branched on.
local scouts =
{
    ['Nachou'] =
    {
        brief   = 416,
        success = 417,
        failure = 418,
        idle    = 415,
    },

    ['Perfaumand'] =
    {
        brief   = 420,
        success = 421,
        failure = 422,
        idle    = 419,
    },
}

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_ULEGUERAND,
    item     = xi.item.RESILIENT_MANTLE,
}

local function runIsLive(player)
    local started = quest:getVar(player, 'RunStart')

    return started ~= 0 and GetSystemTime() - started <= runSeconds
end

local function missCount(player)
    return math.max(0, slidingMen - quest:getVar(player, 'Saved'))
end

local function clearRun(player)
    quest:setVar(player, 'RunStart', 0)
    quest:setVar(player, 'Saved', 0)
    quest:setVar(player, 'Outcome', 0)
end

--- Guiding one stray back on course.
local fighterActions =
{
    onTrigger = function(player, npc)
        if
            not runIsLive(player) or
            quest:getVar(player, 'Saved') >= slidingMen
        then
            return
        end

        quest:setVar(player, 'Saved', quest:getVar(player, 'Saved') + 1)
    end,
}

--- Both scouts, built from the table above so the pair cannot drift apart.
local function scoutActions(scoutName)
    local scout = scouts[scoutName]

    return
    {
        onTrigger = function(player, npc)
            -- Run not started yet: brief the player and start the clock.
            if quest:getVar(player, 'RunStart') == 0 then
                return quest:progressEvent(scout.brief)
            end

            -- Still live and men left to guide, so he has nothing new to say.
            if runIsLive(player) and quest:getVar(player, 'Saved') < slidingMen then
                return quest:event(scout.idle)
            end

            local misses = missCount(player)

            if misses > missAllowance then
                return quest:progressEvent(scout.failure)
            end

            return quest:progressEvent(scout.success, misses)
        end,
    }
end

local function scoutFinishes()
    local handlers = {}

    for _, scout in pairs(scouts) do
        handlers[scout.brief] = function(player, csid, option, npc)
            quest:setVar(player, 'RunStart', GetSystemTime())
            quest:setVar(player, 'Saved', 0)
        end

        handlers[scout.success] = function(player, csid, option, npc)
            quest:setVar(player, 'Outcome', 1)
        end

        handlers[scout.failure] = function(player, csid, option, npc)
            quest:setVar(player, 'Outcome', 2)
        end
    end

    return handlers
end

--- The zone table for a section where the run can be attempted.
local function slopeZone(michilcaTrigger, michilcaFinishes)
    local zone =
    {
        ['Michilca'] = { onTrigger = michilcaTrigger },
        ['Resistance_Fighter'] = fighterActions,
    }

    local finishes = scoutFinishes()

    for name, _ in pairs(scouts) do
        zone[name] = scoutActions(name)
    end

    for csid, handler in pairs(michilcaFinishes) do
        finishes[csid] = handler
    end

    zone.onEventFinish = finishes

    return zone
end

local function payOut(player)
    xi.abyssea.questReward(player, 0, handsSeals)
    clearRun(player)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.SLIP_SLIDIN_AWAY)
end

local function reportTrigger(player, npc)
    local outcome = quest:getVar(player, 'Outcome')

    if outcome == 1 then
        return quest:progressEvent(412)
    elseif outcome == 2 then
        return quest:progressEvent(411)
    end

    return quest:event(410)
end

local function repeatTrigger(player, npc)
    local outcome = quest:getVar(player, 'Outcome')

    if outcome == 1 then
        return quest:progressEvent(412)
    elseif outcome == 2 then
        return quest:progressEvent(411)
    elseif quest:getMustZone(player) then
        return quest:event(413)
    end

    return quest:progressEvent(414)
end

local function failedReport(player, csid, option, npc)
    -- The unit turned back, so the run resets and the quest stays open to retry.
    clearRun(player)
end

local acceptedFinishes =
{
    [412] = function(player, csid, option, npc)
        if quest:complete(player) then
            payOut(player)
        end
    end,

    [411] = failedReport,
}

local completedFinishes =
{
    [412] = function(player, csid, option, npc)
        payOut(player)
    end,

    [411] = failedReport,
    [414] = failedReport,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_ULEGUERAND) >= 2
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] =
        {
            ['Michilca'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(409)
                end,
            },

            onEventFinish =
            {
                [409] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearRun(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] = slopeZone(reportTrigger, acceptedFinishes),
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_ULEGUERAND] = slopeZone(repeatTrigger, completedFinishes),
    },
}

return quest
