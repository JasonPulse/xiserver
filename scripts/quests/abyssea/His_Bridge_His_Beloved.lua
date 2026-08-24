-----------------------------------
-- His Bridge, His Beloved
-----------------------------------
-- Log ID: 8, Quest ID: 32
-- Cheupirudaux   : Abyssea - Vunkerl (E-7), entity 17666746
-- Derelict_Bridge: Abyssea - Vunkerl, entities 17666747 / 17666748 / 17666749 / 17666750
-- !addquest 8 32
-----------------------------------
-- Retail (bg-wiki "His Bridge, His Beloved").
-- |Start=Cheupirudaux (A) (E-7), Abyssea - Vunkerl  |Fame=avun |FLevel=2
-- |Reward=First time: 800 Cruor + KI Crimson abyssite of lenity.
--         Subsequent: 150~850 Cruor. Chance at an Empyrean +1 FEET seal
--         (Aoidos'/Creed/Mavi/Tantra).
--   1. Speak to Cheupirudaux (E-7). He gives a Woodworker's belt and x2 Viscous
--      Spittle.
--   2. Examine the Derelict Bridge at (F-7). "If it creaks, trade x2 Viscous
--      Spittle. If it wavers, trade x4. If it crumbles, trade x5."
--   3. Return to Cheupirudaux.
--   Subsequent runs: he asks for ALL FOUR bridges in the inlet and you supply your
--   own spittle. "It is likely the more bridges you repair, the more Cruor."
--
-- CSIDS DECODED, NOT GUESSED. Cheupirudaux is 17666746 -> zone 217. His own blocks
-- are all ONE BYTE, i.e. stubs; the real programs live on the unnamed HOLDER entity
-- 17666745, which carries csids 1052-1079 for the three quests these three NPCs
-- share. Message attribution below is per-csid, from the byte ranges in that
-- holder's entry table:
--   1052 -> 8239-8255  THE OFFER. 8242 is the two-way menu ("Sure." / "I'd rather
--          not."), 8247 "This ${keyitem-singular} is for you" (the belt),
--          8250/8251 "I have taken it upon myself to prepare the necessary
--          material for you ahead of time", 8252 "You receive ${item-article}"
--          (the spittle). data[] holds 1636 (Woodworker's belt) and 2953
--          (jar_of_viscous_spittle), so the event supplies both ids itself.
--   1053 -> 8256-8258  the reminder ("Why are you still here?").
--   1054 -> 8259       bridge examined with no quest active.
--   1055 -> 8260       THE ASSESSMENT. "It ${choice: 2}[creaks mournfully/wobbles
--          and wavers/begins to splinter and crumble] beneath you." param 2 picks
--          the state, which is why the bridge state is passed from Lua here.
--   1056 -> 8261       "The restoration process is complete."
--   1057 -> 8262       "The restored bridge appears quite sturdy."
--   1058 -> 8263-8267  THE FIRST TURN-IN. 8265 "Let me take that
--          ${keyitem-singular} off your hands", 8266 "Take this for your troubles".
--   1060 -> 8268-8274  the repeat offer. 8271 "This time, I would entreat you to
--          rescue ALL of the fair maidens in this inlet. The one to our northeast,
--          as before. Then one to our south, and two more across the inlet to the
--          east." 8274 "the ${item-singular} I provided to you previously marked
--          the last of my supply" -- hence no spittle on repeats.
--   1062 -> 8275-8280  the repeat turn-in. 8278 "You restored ${number: 0} fair
--          ${choice-plurality: 0}[maiden/maidens]", so the count is param 0.
--
-- BRIDGE ORDER is npc_list order, which matches the order bg-wiki reads them in:
-- 17666747 is the (F-7) bridge to the northeast that the first run uses, and the
-- other three are the south and the two eastern ones the repeat run adds.
--
-- SPITTLE COST is stored per bridge the first time it is assessed, so a player
-- cannot re-roll a "crumbles" bridge into a "creaks" one by walking away.
-----------------------------------

local quest = Quest:new(xi.questLog.ABYSSEA, xi.quest.id.abyssea.HIS_BRIDGE_HIS_BELOVED)

-- Derelict_Bridge entity -> bit. npc_list order; bit 0 is the (F-7) bridge used by
-- the first run.
local bridgeBit =
{
    [17666747] = 0,
    [17666748] = 1,
    [17666749] = 2,
    [17666750] = 3,
}

-- bg-wiki: creaks -> x2, wavers -> x4, crumbles -> x5. Index is the `choice: 2`
-- param the assessment event expects.
local spittleForState = { [0] = 2, 4, 5 }

-- bg-wiki lists FEET seals for this quest, so these are 3199/3196/3205/3191 and not
-- the same jobs' other slots.
local feetSeals =
{
    xi.item.AOIDOS_SEAL_FEET,
    xi.item.CREED_SEAL_FEET,
    xi.item.MAVI_SEAL_FEET,
    xi.item.TANTRA_SEAL_FEET,
}

local firstCruor = 800

quest.reward =
{
    fameArea = xi.fameArea.ABYSSEA_VUNKERL,
}

--- Assessed state for one bridge, rolled once and then remembered.
local bridgeState = function(player, bit1)
    local varName = string.format('Bridge%dState', bit1)
    local state   = quest:getVar(player, varName)

    -- Stored as 1..3 so that 0 can mean "not yet assessed".
    if state == 0 then
        state = math.random(1, 3)
        quest:setVar(player, varName, state)
    end

    return state - 1
end

local isRepaired = function(player, bit1)
    return bit.band(quest:getVar(player, 'Bridges'), bit.lshift(1, bit1)) ~= 0
end

local markRepaired = function(player, bit1)
    local mask = quest:getVar(player, 'Bridges')

    quest:setVar(player, 'Bridges', bit.bor(mask, bit.lshift(1, bit1)))
end

local repairedCount = function(player)
    local mask  = quest:getVar(player, 'Bridges')
    local count = 0

    for bit1 = 0, 3 do
        if bit.band(mask, bit.lshift(1, bit1)) ~= 0 then
            count = count + 1
        end
    end

    return count
end

local clearRun = function(player)
    quest:setVar(player, 'Bridges', 0)

    for bit1 = 0, 3 do
        quest:setVar(player, string.format('Bridge%dState', bit1), 0)
    end
end

--- The bridge behaves the same whether this is the first run or a repeat, so both
--- sections share it.
local bridgeActions =
{
    onTrigger = function(player, npc)
        local bit1 = bridgeBit[npc:getID()]

        if bit1 == nil then
            return
        end

        if isRepaired(player, bit1) then
            return quest:event(1057)
        end

        return quest:event(1055, bridgeState(player, bit1))
    end,

    onTrade = function(player, npc, trade)
        local bit1 = bridgeBit[npc:getID()]

        if bit1 == nil or isRepaired(player, bit1) then
            return
        end

        local needed = spittleForState[bridgeState(player, bit1)]

        -- tradeHasExactly confirms the items itself when it returns true, so there
        -- is no confirmTrade call here.
        if npcUtil.tradeHasExactly(trade, { { xi.item.JAR_OF_VISCOUS_SPITTLE, needed } }) then
            markRepaired(player, bit1)

            return quest:event(1056)
        end
    end,
}

quest.sections =
{
    -- bg-wiki lists no |Previous= and no |Quest Reqs=, only fame level 2.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getFameLevel(xi.fameArea.ABYSSEA_VUNKERL) >= 2
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Cheupirudaux'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(1052)
                end,
            },

            onEventFinish =
            {
                [1052] = function(player, csid, option, npc)
                    quest:begin(player)
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.WOODWORKERS_BELT)
                    npcUtil.giveItem(player, { { xi.item.JAR_OF_VISCOUS_SPITTLE, 2 } })
                end,
            },
        },
    },

    -- First run: only the northeast bridge is asked for.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED
        end,

        [xi.zone.ABYSSEA_VUNKERL] =
        {
            ['Derelict_Bridge'] = bridgeActions,

            ['Cheupirudaux'] =
            {
                onTrigger = function(player, npc)
                    if repairedCount(player) > 0 then
                        return quest:progressEvent(1058)
                    end

                    return quest:event(1053)
                end,
            },

            onEventFinish =
            {
                [1058] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        clearRun(player)
                        player:delKeyItem(xi.ki.WOODWORKERS_BELT)
                        npcUtil.giveKeyItem(player, xi.ki.CRIMSON_ABYSSITE_OF_LENITY)
                        xi.abyssea.questReward(player, firstCruor, feetSeals)
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
            ['Derelict_Bridge'] = bridgeActions,

            ['Cheupirudaux'] =
            {
                onTrigger = function(player, npc)
                    local repaired = repairedCount(player)

                    if repaired > 0 then
                        return quest:progressEvent(1062, repaired)
                    elseif quest:getMustZone(player) then
                        return quest:event(1053)
                    end

                    return quest:progressEvent(1060)
                end,
            },

            onEventFinish =
            {
                [1060] = function(player, csid, option, npc)
                    -- Re-accepting the quest is what lets the first-run section run
                    -- again; 8274 says he has no spittle left to hand out, so none
                    -- is given here.
                    clearRun(player)
                    npcUtil.giveKeyItem(player, xi.ki.WOODWORKERS_BELT)
                end,

                [1062] = function(player, csid, option, npc)
                    -- "It is likely the more bridges you repair, the more Cruor you
                    -- receive." bg-wiki's band is 150~850, so this walks that band
                    -- by bridge count rather than paying a flat sum.
                    local repaired = repairedCount(player)
                    local cruor    = 150 + (repaired - 1) * 233

                    clearRun(player)
                    player:delKeyItem(xi.ki.WOODWORKERS_BELT)
                    xi.abyssea.questReward(player, cruor, feetSeals)
                    xi.quest.setMustZone(player, xi.questLog.ABYSSEA, xi.quest.id.abyssea.HIS_BRIDGE_HIS_BELOVED)
                end,
            },
        },
    },
}

return quest
