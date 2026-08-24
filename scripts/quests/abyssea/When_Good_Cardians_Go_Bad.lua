-----------------------------------
-- When Good Cardians Go Bad
-----------------------------------
-- Log ID: 8, Quest ID: 28
-- Apururu  : Abyssea - Tahrongi (H-12), entity 16962091
-- Cardians : Abyssea - Tahrongi, entities 16962129 .. 16962142
-- !addquest 8 28
-----------------------------------
-- Retail (bg-wiki "When Good Cardians Go Bad").
-- |Start=Apururu (A) (H-12), Abyssea - Tahrongi  |Fame=atah |FLevel=4
-- |Previous=His Box, His Beloved  |Repeatable=Yes
-- |Reward=KI Viridian abyssite of guerdon first time, 400 Cruor subsequently
--   1. "Talk to Apururu (A) at (H-12)." "Note: Zoning resets progress on this quest."
--   2. "Travel around to the five cardians (2 to 6 of Diamonds). Two guard the main
--      camp, one is at each of the other three encampments."
--   3. "Some, or all, of the Cardians will give odd responses." "Be careful, as one
--      incorrect word might be all that is wrong with a cardian's message."
--      "Additionally, they may have correct responses but if they speak with hollow
--      stars, that response is still incorrect."
--   4. "Report which Cardians gave the odd responses to Apururu (A)." "You must
--      choose perfect answers or the quest will not be completed."
--
-- CSIDS VERIFIED ON THE LIVE CLIENT, fired at the puppet in Abyssea - Tahrongi:
--   376 -> "Thanks in no small part to your assistance, we now have a Cardian
--          stationed at each and every one..." then the brief, which itself states
--          "There are five of them in all" and the zoning warning     THE OFFER
--   377 -> the same brief again                                     the reminder
--   378 -> "Good to see you back! Well? Were you able to find out anything?"
--                                                                    the turn-in
--   380 -> "I've afraid I have my hands full dealing with our rogue Cardian. Come
--          back when things have settled-wettled down a bit."         the cooldown
--   381 -> "Ah, <pc>. Could I trouble-wouble you to check on our Cardians again?"
--                                                              the repeat offer
--   302-305 belong to the PREVIOUS quest, not this one.
--
-- THE REPORT MENU IS DECODED, message 8030, and it is a multi-select:
--     0 Six of Diamonds.        4 Two of Diamonds.
--     1 Five of Diamonds.       5 Sorry, let me start over...
--     2 Four of Diamonds.       6 That's all of them.
--     3 Three of Diamonds.      7 I'll get back to you on that...
-- Note it runs SIX down to TWO, the reverse of the natural order, which is why the
-- option-to-rank mapping below is written out rather than computed.
--
-- THE CARDIAN LINES ARE PARAMETERISED PLAIN TEXT, not cutscenes. The cardian entities
-- own no event programs at all; messages 8045-8048 are the four things they can say,
-- and each carries two Multiple Choice parameters:
--     parameter 1  the star, index 0 solid and 1 hollow
--     parameter 2  the wording, index 0 right and 1 wrong
-- A cardian is faulty if EITHER is index 1, which is exactly the pair of tells
-- bg-wiki describes. Apururu's own 378 references 8045 and 8046, i.e. she recites them
-- back, which is how the pairing was confirmed.
--
-- FOURTEEN ENTITIES, FIVE CARDIANS. The duplicates are the same rank standing at
-- different encampments and they share an internal name, so hooking the five names
-- covers all fourteen and each rank stays one logical cardian.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.WHEN_GOOD_CARDIANS_GO_BAD)

-- Bit order is Two through Six, low bit first.
local cardianRanks =
{
    'Two_of_Diamonds',
    'Three_of_Diamonds',
    'Four_of_Diamonds',
    'Five_of_Diamonds',
    'Six_of_Diamonds',
}

-- Menu 8030 lists Six first, so option 0 is the HIGHEST rank.
local optionToRank =
{
    [0] = 5,
    [1] = 4,
    [2] = 3,
    [3] = 2,
    [4] = 1,
}

local optionStartOver = 5
local optionSubmit    = 6

local cardianLines =
{
    8045,
    8046,
    8047,
    8048,
}

local cruorRepeat = 400

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_TAHRONGI,
}

local function stateVar(rank)
    return string.format('Cardian%d', rank)
end

--- Roll every cardian's line, star and wording. Apururu's brief says their condition
--- "is known to fluctuate", and bg-wiki that zoning resets progress, so this is
--- re-rolled on every entry rather than once per quest.
local function rollCardians(player)
    local anyFaulty = false

    for rank = 1, #cardianRanks do
        local line  = math.random(0, #cardianLines - 1)
        local star  = math.random(0, 1)
        local word  = math.random(0, 1)

        quest:setVar(player, stateVar(rank), line + star * 4 + word * 8)

        if star == 1 or word == 1 then
            anyFaulty = true
        end
    end

    -- "Some, or all, of the Cardians will give odd responses", so a clean sweep is
    -- not a legal roll. Spoil one at random.
    if not anyFaulty then
        local rank  = math.random(#cardianRanks)
        local state = quest:getVar(player, stateVar(rank))

        quest:setVar(player, stateVar(rank), state + 4)
    end

    quest:setVar(player, 'Heard', 0)
    quest:setVar(player, 'Picked', 0)
end

local function cardianState(player, rank)
    local state = quest:getVar(player, stateVar(rank))

    return state % 4, math.floor(state / 4) % 2, math.floor(state / 8) % 2
end

local function isFaulty(player, rank)
    local _, star, word = cardianState(player, rank)

    return star == 1 or word == 1
end

local function faultyMask(player)
    local mask = 0

    for rank = 1, #cardianRanks do
        if isFaulty(player, rank) then
            mask = bit.bor(mask, bit.lshift(1, rank - 1))
        end
    end

    return mask
end

local function heardAll(player)
    local full = bit.lshift(1, #cardianRanks) - 1

    return bit.band(quest:getVar(player, 'Heard'), full) == full
end

--- One cardian speaking. The rank is taken from the name so all fourteen entities
--- share one handler.
local function cardianActions(rank)
    return
    {
        onTrigger = function(player, npc)
            local ID = zones[player:getZoneID()]
            local line, star, word = cardianState(player, rank)

            quest:setVar(player, 'Heard', bit.bor(quest:getVar(player, 'Heard'), bit.lshift(1, rank - 1)))

            -- 8045-8048 read their star from parameter 1 and their wording from
            -- parameter 2, so parameter 0 goes unused.
            player:messageSpecial(ID.text.CARDIAN_GREETING + line, 0, star, word)
        end,
    }
end

local function reportHandlers(onSuccess)
    return
    {
        onEventUpdate = function(player, csid, option, npc)
            if option == optionStartOver then
                quest:setVar(player, 'Picked', 0)
            else
                local rank = optionToRank[option]

                if rank ~= nil then
                    local picked = quest:getVar(player, 'Picked')

                    quest:setVar(player, 'Picked', bit.bxor(picked, bit.lshift(1, rank - 1)))
                end
            end

            player:updateEvent(quest:getVar(player, 'Picked'))
        end,

        onEventFinish = function(player, csid, option, npc)
            -- Anything other than "That's all of them" is a walk-away, including
            -- option 7, "I'll get back to you on that...", so the picks stand.
            if option ~= optionSubmit then
                return
            end

            -- "You must choose perfect answers or the quest will not be completed."
            if quest:getVar(player, 'Picked') == faultyMask(player) then
                onSuccess(player)
            end

            rollCardians(player)
        end,
    }
end

--- The zone table shared by the accepted and repeat sections.
local function tahrongiZone(apururuTrigger, report)
    local zone =
    {
        ['Apururu'] = { onTrigger = apururuTrigger },

        -- "Zoning resets progress on this quest."
        onZoneIn = function(player, prevZone)
            rollCardians(player)
        end,

        onEventUpdate =
        {
            [378] = report.onEventUpdate,
        },

        onEventFinish =
        {
            [378] = report.onEventFinish,
        },
    }

    for rank, rankName in ipairs(cardianRanks) do
        zone[rankName] = cardianActions(rank)
    end

    return zone
end

local function acceptedTrigger(player, npc)
    if not heardAll(player) then
        return quest:event(377)
    end

    return quest:progressEvent(378)
end

local function repeatTrigger(player, npc)
    if quest:getMustZone(player) then
        return quest:event(380)
    elseif heardAll(player) then
        return quest:progressEvent(378)
    end

    return quest:progressEvent(381)
end

local function finishRun(player)
    quest:setVar(player, 'Picked', 0)
    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.WHEN_GOOD_CARDIANS_GO_BAD)
end

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getQuestStatus(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HIS_BOX_HIS_BELOVED) == xi.questStatus.QUEST_COMPLETED and
                player:getFameLevel(xi.fameArea.ABYSSEA_TAHRONGI) >= 4
        end,

        [xi.zone.ABYSSEA_TAHRONGI] =
        {
            ['Apururu'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(376)
                end,
            },

            onEventFinish =
            {
                [376] = function(player, csid, option, npc)
                    quest:begin(player)
                    rollCardians(player)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] = tahrongiZone(acceptedTrigger, reportHandlers(function(player)
            if quest:complete(player) then
                npcUtil.giveKeyItem(player, xi.ki.VIRIDIAN_ABYSSITE_OF_GUERDON)
                finishRun(player)
            end
        end)),
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_TAHRONGI] = tahrongiZone(repeatTrigger, reportHandlers(function(player)
            xi.abyssea.questReward(player, cruorRepeat, nil)
            finishRun(player)
        end)),
    },
}

return quest
