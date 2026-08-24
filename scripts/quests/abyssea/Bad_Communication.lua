-----------------------------------
-- Bad Communication
-----------------------------------
-- Log ID: 8, Quest ID: 33
-- Ferdechiond : Abyssea - Vunkerl (I-9), entity 17666751
-- qm          : Abyssea - Vunkerl, entities 17666752 / 17666753 / 17666754
-- !addquest 8 33
-----------------------------------
-- Retail (bg-wiki "Bad Communication").
-- |Start=Ferdechiond (A) (I-9), Abyssea - Vunkerl  |Fame=avun |FLevel=2
-- |Reward=First time: 700~1,500 Cruor. Subsequent: 300~800 Cruor. Chance at an
--         Empyrean +1 FEET seal (Orison/Ferine/Raider's/Unkai).
--   1. Speak to Ferdechiond (I-9) near Conflux #00. "You will receive KI Espionage
--      pearlsack."
--   2. "Travel to and examine the 3 ??? that Ferdechiond marks on the map. They are
--      located at (H-10), (G-8), and (E-11)."
--   3. Travel back to Ferdechiond to complete the quest.
--   "The quality of the reward is based on how quickly the quest is completed.
--    10+ minutes: 700 first / 300 after. 8~9 minutes: 1,000 / 600. 7 minutes or
--    less: 1,500 / 800. Your time begins when the quest is accepted, and ends when
--    the final ??? is selected rather than when you return to the NPC."
--
-- CSIDS DECODED, NOT GUESSED. Ferdechiond's own blocks are ONE BYTE each, i.e.
-- stubs; the real programs sit on the unnamed HOLDER entity 17666745 (csids
-- 1052-1079 cover the three quests these NPCs share). Per-csid attribution from
-- that holder's byte ranges:
--   1063 -> 8281-8299  THE OFFER. 8288 is the two-way menu ("Certainly!" / "Not
--          today."), 8294 "There are three linkpearls that you must investigate",
--          8295 names (H-10), (G-8) and (E-11), 8296 "I shall mark them off on your
--          map for you", 8297/8298 "here is a sack of fresh linkpearls".
--   1064 -> 8295/8300  the reminder ("Did I not tell you that time is of the
--          essence!?").
--   1065 -> 8301-8303  first pearl, working. "But we cannot yet rest easy! You must
--          check the remaining TWO locations."
--   1066 -> 8301/8304/8305  second pearl, working. "Hurry to your FINAL
--          destination!"
--   1067 -> 8301/8306-8310  the damaged pearl. 8306 "There is no response",
--          8307 "You replace the malfunctioning linkpearl with a fresh one from the
--          pearlsack", 8310 "I shall have your reward ready upon your return."
--   1068 -> 8311       a pearl already dealt with on this run.
--   1069 -> 8312-8318  THE TURN-IN, and it carries all three speed lines itself:
--          8313 "Thorough, and swift. That's what I like to see!", 8316 "And a
--          fairly swift return, at that", 8317 "It took you a fair while". So the
--          band is a param, not three separate csids.
--   1070 -> 8318       his post-completion line.
--   1071 -> 8319-8322  the repeat offer.
--
-- ??? ROLE IS FIXED BY THE CLIENT, not by visit order. Each qm carries exactly one
-- of 1065/1066/1067 as a stub plus the shared 1068, so the assignment below is read
-- off the DAT rather than chosen: 17666752 is the "first" pearl, 17666753 the
-- "second", and 17666754 is the damaged one you replace. That matches the order
-- bg-wiki lists the coordinates in.
--
-- All three qm entities in this quest share the name 'qm' with the five belonging to
-- Scattered Shells, Scattered Mind, so the handler returns nil for any id that is
-- not one of ours. Without that, whichever quest won on priority would swallow the
-- other's ???.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.BAD_COMMUNICATION)

-- qm entity -> { bit, csid }. Roles are the client's, see the header.
local pearls =
{
    [17666752] = { 0, 1065 },
    [17666753] = { 1, 1066 },
    [17666754] = { 2, 1067 },
}

local allPearls = 0x07 -- three bits

-- bg-wiki lists FEET seals for this quest: 3192/3198/3195/3201.
local feetSeals =
{
    xi.item.ORISON_SEAL_FEET,
    xi.item.FERINE_SEAL_FEET,
    xi.item.RAIDERS_SEAL_FEET,
    xi.item.UNKAI_SEAL_FEET,
}

-- bg-wiki's three bands, in the order the turn-in event's lines run: swift, fair,
-- slow. Index is the param handed to csid 1069.
local cruorFirst  = { [0] = 1500, 1000, 700 }
local cruorRepeat = { [0] = 800,  600,  300 }

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

--- 0 for 7 minutes or less, 1 for 8~9, 2 for 10+.
local speedBand = function(player)
    local finished = quest:getVar(player, 'Finished')
    local started  = quest:getVar(player, 'Started')

    if started == 0 or finished <= started then
        return 2
    end

    local elapsed = finished - started

    if elapsed <= 7 * 60 then
        return 0
    elseif elapsed < 10 * 60 then
        return 1
    end

    return 2
end

local clearRun = function(player)
    quest:setVar(player, 'Pearls', 0)
    quest:setVar(player, 'Started', 0)
    quest:setVar(player, 'Finished', 0)
end

--- Shared by the first run and the repeat: the pearls behave identically.
local pearlActions =
{
    onTrigger = function(player, npc)
        local entry = pearls[npc:getID()]

        if entry == nil then
            return
        end

        local bit1 = entry[1]
        local mask = quest:getVar(player, 'Pearls')

        if bit.band(mask, bit.lshift(1, bit1)) ~= 0 then
            return quest:event(1068)
        end

        mask = bit.bor(mask, bit.lshift(1, bit1))
        quest:setVar(player, 'Pearls', mask)

        -- "ends when the final ??? is selected rather than when you return."
        if mask == allPearls then
            quest:setVar(player, 'Finished', GetSystemTime())
        end

        return quest:event(entry[2])
    end,
}

quest.sections =
{
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_VUNKERL) >= 2
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Ferdechiond'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1063)
                end,
            },

            onEventFinish =
            {
                [1063] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearRun(player)
                    -- "Your time begins when the quest is accepted."
                    quest:setVar(player, 'Started', GetSystemTime())
                    npcUtil.giveKeyItem(player, xi.ki.ESPIONAGE_PEARLSACK)
                end,
            },
        },
    },

    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['qm'] = pearlActions,

            ['Ferdechiond'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Pearls') == allPearls then
                        return quest:progressEvent(1069, speedBand(player))
                    end

                    return quest:event(1064)
                end,
            },

            onEventFinish =
            {
                [1069] = function(player, csid, option, npc)
                    local band = speedBand(player)

                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.ESPIONAGE_PEARLSACK)
                        xi.abyssea.questReward(player, cruorFirst[band], feetSeals)
                        clearRun(player)
                    end
                end,
            },
        },
    },

    -- Repeatable. bg-wiki: "Zoning is required to repeat this quest."
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_COMPLETED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['qm'] = pearlActions,

            ['Ferdechiond'] =
            {
                onTrigger = function(player, npc)
                    if quest:getVar(player, 'Pearls') == allPearls then
                        return quest:progressEvent(1069, speedBand(player))
                    elseif quest:getVar(player, 'Started') ~= 0 then
                        return quest:event(1064)
                    elseif quest:getMustZone(player) then
                        return quest:event(1070)
                    end

                    return quest:progressEvent(1071)
                end,
            },

            onEventFinish =
            {
                [1069] = function(player, csid, option, npc)
                    local band = speedBand(player)

                    player:delKeyItem(xi.ki.ESPIONAGE_PEARLSACK)
                    xi.abyssea.questReward(player, cruorRepeat[band], feetSeals)
                    clearRun(player)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.BAD_COMMUNICATION)
                end,

                [1071] = function(player, csid, option, npc)
                    clearRun(player)
                    quest:setVar(player, 'Started', GetSystemTime())
                    npcUtil.giveKeyItem(player, xi.ki.ESPIONAGE_PEARLSACK)
                end,
            },
        },
    },
}

return quest
