-----------------------------------
-- Ward Warden I
-- Ward Warden II
-- Desert Rain I
-- Desert Rain II
-- Crimson Carpet I
-- Crimson Carpet II
-----------------------------------
-- Abyssea Resistance Sapper operations. The six titles above are declared on their
-- own lines because build_ledger.py reads only the first 8 lines of a file, and each
-- bg-wiki row ("Ward Warden I (Vunkerl)" and so on) normalises to the same key once
-- its parenthetical is stripped -- so these six lines resolve all EIGHTEEN rows to
-- this module, which is where the implementation actually lives.
--
-- SIX bg-wiki quests x THREE zones = 18 quests, all driven by ONE client menu on
-- the Resistance Sapper. They are not eighteen separate scripts.
--
-- All three sappers own the SAME csids -- only the message ids behind them differ
-- per zone, which is the client's business, not ours:
--     Attohwa   17658656 (zone 215)
--     Misareaux 17662779 (zone 216)
--     Vunkerl   17666772 (zone 217)
--   1503  the briefing, and it carries the six-operation menu
--   1504  the abandon/quit path
--   1505  the turn-in, which grades four ways
--   1506  the failure line (sack burst / chocobo fled / fluid wasted)
--   1507  the filled-bottle handover for the trap operations
--
-- THE MENU IS THE FAMILY. Vunkerl message 7949 is the whole thing:
--     Undertake which operation?
--       Ward Warden I.      -> option 0
--       Ward Warden II.     -> option 1
--       Desert Rain I.      -> option 2
--       Desert Rain II.     -> option 3
--       Crimson Carpet I.   -> option 4
--       Crimson Carpet II.  -> option 5
--       Nothing for now.    -> option 6
--
-- EVERY MAPPING BELOW COMES OUT OF THE SAPPER'S OWN data[] TABLE, read with
-- csidmsg.load(217, 17666772). That table is the Rosetta stone for the family --
-- it lists, per operation, the key item and the briefing / quit / four grade /
-- failure message ids in a fixed order:
--     [217, 0, 7948, 7949, 1,2,3,4,5,
--      1627, 7950..7953, 7942, 7954, <map coords>, 7955, 7956,   <- Ward Warden I
--            7968..7974,                                         <- Ward Warden II
--      1628, 7985..7988, <map coords>, 7989, 7990,               <- Desert Rain I
--            8001..8007,                                         <- Desert Rain II
--      1629, 8018..8021,                                         <- Crimson Carpet I
--      1631, 8032..8035,                                         <- Crimson Carpet II
--      ...quit paths, then six 4-grade turn-in sets, then six failure lines...]
-- 1631/1632 (Weakening trap fluid and its bottle) were found only by reading that
-- table -- Crimson Carpet II uses the FORE trap and a different fluid from
-- Crimson Carpet I's rear trap, which no walkthrough spells out.
--
-- THREE MECHANICS, NOT SIX. The operations pair up:
--   sack    Ward Warden I  / Desert Rain I   -- pack a Repair Trunk, push your luck
--   chocobo Ward Warden II / Desert Rain II  -- escort a pack chocobo, keep it calm
--   trap    Crimson Carpet I / II            -- infuse a trap from a stated distance
-- Ward Warden hauls repair materials, Desert Rain hauls ensorceled provisions; that
-- is the only difference within a pair, and it is what selects the sack and trunk.
--
-- ONE PER VANA'DIEL DAY across all three zones, per bg-wiki: "Only one Ward Warden
-- / Desert Rain / Crimson Carpet quest can be completed per Vana'dielian day,
-- regardless of Abyssea area."
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.abyssea = xi.abyssea or {}
xi.abyssea.sapper = xi.abyssea.sapper or {}

-- Menu option -> operation. Index is the option the client returns from message
-- 7949; option 6 ("Nothing for now.") is simply not in the table.
xi.abyssea.sapper.op =
{
    WARD_WARDEN_I    = 0,
    WARD_WARDEN_II   = 1,
    DESERT_RAIN_I    = 2,
    DESERT_RAIN_II   = 3,
    CRIMSON_CARPET_I = 4,
    CRIMSON_CARPET_II = 5,
}

local sackOp, chocoboOp, trapOp = 1, 2, 3

-- Per-operation constants, all read out of the sapper's data[] table.
local operations =
{
    [0] = { mechanic = sackOp,    keyItem = xi.ki.MAGICKED_HEMPEN_SACK, cargo = 'materials' },
    [1] = { mechanic = chocoboOp,                                       cargo = 'materials' },
    [2] = { mechanic = sackOp,    keyItem = xi.ki.MAGICKED_FLAXEN_SACK, cargo = 'provisions' },
    [3] = { mechanic = chocoboOp,                                       cargo = 'provisions' },
    [4] = { mechanic = trapOp,    keyItem = xi.ki.PARALYSIS_TRAP_FLUID,
            bottle = xi.ki.PARALYSIS_TRAP_FLUID_BOTTLE, trap = 'Rear_Trap'  },
    [5] = { mechanic = trapOp,    keyItem = xi.ki.WEAKENING_TRAP_FLUID,
            bottle = xi.ki.WEAKENING_TRAP_FLUID_BOTTLE, trap = 'Fore_Trap'  },
}

-- The eighteen quest ids run in a regular block, operation-major then zone:
--   124 Ward Warden I    (Attohwa, Misareaux, Vunkerl)
--   127 Ward Warden II   ... through 141 Crimson Carpet II (Vunkerl)
-- so the id is arithmetic rather than eighteen hardcoded names.
local questBase = 124

local zoneIndex =
{
    [xi.zone.ABYSSEA_ATTOHWA]   = 0,
    [xi.zone.ABYSSEA_MISAREAUX] = 1,
    [xi.zone.ABYSSEA_VUNKERL]   = 2,
}

-- Fame is per-zone: bg-wiki's |Fame= is aatt / amis / avun respectively, so an
-- Attohwa run must not read or award Vunkerl fame.
local fameFor =
{
    [xi.zone.ABYSSEA_ATTOHWA]   = xi.fameArea.ABYSSEA_ATTOHWA,
    [xi.zone.ABYSSEA_MISAREAUX] = xi.fameArea.ABYSSEA_MISAREAUX,
    [xi.zone.ABYSSEA_VUNKERL]   = xi.fameArea.ABYSSEA_VUNKERL,
}

xi.abyssea.sapper.questId = function(opId, zoneId)
    local zi = zoneIndex[zoneId]
    if zi == nil then
        return nil
    end

    return questBase + opId * 3 + zi
end

-----------------------------------
-- Shared state
--
-- Everything here is per-character and deliberately short-lived: bg-wiki says the
-- sack "will disappear when you zone or log out", so the working state lives in
-- char vars that the operation clears on finish or failure rather than in anything
-- that outlives the run.
-----------------------------------
local varOp     = 'SapperOp'       -- active operation + 1 (0 means idle)
local varPacked = 'SapperPacked'   -- accumulated burden
local varCap    = 'SapperCap'      -- rolled capacity for this run
local varUnits  = 'SapperUnits'    -- how many items went in, for grading
local varTrap   = 'SapperTrap'     -- primed trap entity id
local varDist   = 'SapperDist'     -- required distance in yalms
local varGrade  = 'SapperGrade'    -- 0..3, set at the moment of truth
local varDay    = 'SapperDay'      -- Vana'diel day of the last completion

xi.abyssea.sapper.activeOp = function(player)
    return player:getCharVar(varOp) - 1
end

local clearRun = function(player)
    for _, v in ipairs({ varOp, varPacked, varCap, varUnits, varTrap, varDist, varGrade }) do
        player:setCharVar(v, 0)
    end
end

-- bg-wiki: one of these operations per Vana'diel day, across all three zones.
xi.abyssea.sapper.doneToday = function(player)
    return player:getCharVar(varDay) == VanadielUniqueDay()
end

-----------------------------------
-- The sack operations (Ward Warden I, Desert Rain I)
--
-- bg-wiki: "There are three types of materials: sharp, jagged, and round. The more
-- you pack, the more rewards you get, but if you pack too much it will tear... The
-- former puts a heavier burden on the bag, so it's a good idea to start with the
-- sharp ones, and if the message changes, lower the rank of the materials."
-- So pointy is heaviest and round lightest, and the five condition strings
-- (message 8050-8054 in Vunkerl) are the player's only read on remaining room.
--
-- The capacity is ROLLED PER RUN, which is retail: bg-wiki states outright that
-- "the size of the bag is random to some extent, and the same packing method does
-- not always give the same result." The band below is ours; the randomness is not.
-----------------------------------
local burden = { [1] = 7, [2] = 5, [3] = 3 } -- pointy, jagged, round

xi.abyssea.sapper.beginPacking = function(player)
    player:setCharVar(varPacked, 0)
    player:setCharVar(varUnits, 0)
    player:setCharVar(varCap, math.random(28, 52))
end

-- Returns the condition band 0..4 for message 8050-8054, or nil once ruptured.
xi.abyssea.sapper.sackCondition = function(player)
    local cap = player:getCharVar(varCap)
    if cap == 0 then
        return 0
    end

    local frac = player:getCharVar(varPacked) / cap

    if frac >= 1.0 then
        return nil
    elseif frac >= 0.85 then
        return 4
    elseif frac >= 0.65 then
        return 3
    elseif frac >= 0.40 then
        return 2
    elseif frac >= 0.20 then
        return 1
    end

    return 0
end

--- Cram one item. Returns true if the sack survived, false if it ruptured.
xi.abyssea.sapper.cram = function(player, kind)
    local weight = burden[kind]
    if weight == nil then
        return true
    end

    player:setCharVar(varPacked, player:getCharVar(varPacked) + weight)
    player:setCharVar(varUnits, player:getCharVar(varUnits) + 1)

    return xi.abyssea.sapper.sackCondition(player) ~= nil
end

-----------------------------------
-- The trap operations (Crimson Carpet I / II)
--
-- Message 7873's menu, in order: Nothing / Prime the trap for infusion / Commence
-- trap fluid infusion / Cease trap fluid infusion / Cease infusing other trap.
-- Priming states the distance (7876 "Please stand ${number: 0} yalms away"), and
-- 7878 grades the pour five ways -- paltry, small, moderate, substantial, hefty --
-- off how close you stood to it. bg-wiki's three usable distances: 1 yalm is just
-- inside the fringe, 2 just beside it, 5 the maximum.
-----------------------------------
local trapDistances = { 1, 2, 5 }

xi.abyssea.sapper.primeTrap = function(player, npc)
    local dist = trapDistances[math.random(1, #trapDistances)]

    player:setCharVar(varTrap, npc:getID())
    player:setCharVar(varDist, dist)

    return dist
end

--- Grade the infusion 0..4 (paltry..hefty) from how close the player stood to the
--- stated distance. Exact is best; every yalm out costs a band.
xi.abyssea.sapper.infuse = function(player, npc)
    local want = player:getCharVar(varDist)
    if want == 0 or player:getCharVar(varTrap) ~= npc:getID() then
        return nil
    end

    local off = math.abs(player:checkDistance(npc) - want)
    local band = 4 - math.floor(off)

    return math.max(0, math.min(4, band))
end

-----------------------------------
-- Grading and reward
--
-- The turn-in (1505) has FOUR outcomes per operation, best first in the sapper's
-- data[]: e.g. Ward Warden I is 7963 "literally bursting", 7964 "a goodly amount",
-- 7965 "room still to fit more", 7966 "erred on the side of caution".
--
-- bg-wiki: "Varying amount of Cruor (Max: 1,000) and Resistance Credits (Max: 70)"
-- plus "0~1 of: any Empyrean Armor +1 Feet seal". The maxima are retail; the
-- per-grade split below is ours, anchored on those ceilings.
-----------------------------------
local cruorForGrade   = { [0] = 1000, 650, 400, 150 }
local creditsForGrade = { [0] = 70,   50,  30,  15  }

-- bg-wiki says FEET seals specifically, so these are the feet ids (3192/3195/3198/
-- 3201) and not the hands pieces they sit beside in the enum.
local feetSeals =
{
    xi.item.ORISON_SEAL_FEET,
    xi.item.RAIDERS_SEAL_FEET,
    xi.item.FERINE_SEAL_FEET,
    xi.item.UNKAI_SEAL_FEET,
}

--- Turn a mechanic-specific measure into the 0..3 grade the turn-in event expects.
xi.abyssea.sapper.grade = function(player, opId)
    local mechanic = operations[opId].mechanic

    if mechanic == sackOp then
        local cap = player:getCharVar(varCap)
        local frac = cap > 0 and (player:getCharVar(varPacked) / cap) or 0

        if frac >= 0.85 then
            return 0
        elseif frac >= 0.65 then
            return 1
        elseif frac >= 0.40 then
            return 2
        end

        return 3
    end

    -- Trap and chocobo runs record their band as they happen.
    return math.max(0, math.min(3, 3 - player:getCharVar(varGrade)))
end

xi.abyssea.sapper.reward = function(player, opId, grade)
    local zoneId = player:getZoneID()
    local ID     = zones[zoneId]
    local cruor  = cruorForGrade[grade]

    player:addCurrency('cruor', cruor)
    player:messageSpecial(ID.text.CRUOR_OBTAINED, cruor, player:getCurrency('cruor'))
    player:addCurrency('resistance_credit', creditsForGrade[grade])

    -- "0~1 of: any Empyrean Armor +1 Feet seal" -- the drop is not guaranteed, and
    -- the rate is unpublished, so the best grade is the only one that can roll it.
    if grade == 0 and math.random(1, 100) <= 30 then
        npcUtil.giveItem(player, feetSeals[math.random(1, #feetSeals)])
    end

    player:setCharVar(varDay, VanadielUniqueDay())
    clearRun(player)
end

xi.abyssea.sapper.fail = function(player)
    clearRun(player)
end

xi.abyssea.sapper.accept = function(player, opId)
    local entry = operations[opId]

    player:setCharVar(varOp, opId + 1)

    if entry.keyItem ~= nil then
        npcUtil.giveKeyItem(player, entry.keyItem)
    end

    if entry.mechanic == sackOp then
        xi.abyssea.sapper.beginPacking(player)
    end
end

xi.abyssea.sapper.operation = function(opId)
    return operations[opId]
end

-----------------------------------
-- NPC handlers
--
-- csid 1503 is a TWO-STAGE event: message 7949 picks the operation, then that
-- operation's briefing runs and 7954 asks Yes/No. The selection therefore arrives
-- on the UPDATE and the confirmation on the FINISH, which is the same shape
-- dominion.lua drives its sergeant menus with. Reading a packed operation+answer
-- out of the finish option alone would be guesswork; this does not have to guess.
--
-- The six operation values come from the sapper's data[], where 7949 is followed by
-- 1,2,3,4,5 -- an implicit 0 plus those five, i.e. options 0..5 in menu order, with
-- 6 being "Nothing for now."
-----------------------------------
local varPick = 'SapperPick'

xi.abyssea.sapper.sapperOnTrigger = function(player, npc)
    local opId = xi.abyssea.sapper.activeOp(player)

    -- Mid-operation: either grade it or offer the way out.
    if opId >= 0 then
        local entry = operations[opId]

        if entry.mechanic == trapOp and player:hasKeyItem(entry.bottle) then
            player:startEvent(1505, opId)
        elseif
            entry.mechanic == sackOp and
            player:getCharVar(varUnits) > 0
        then
            player:startEvent(1505, opId)
        else
            player:startEvent(1504, opId)
        end

        return
    end

    -- bg-wiki gates the whole family behind resistance clearance; 7947 is the
    -- "you do not have clearance" line.
    if player:getFameLevel(fameFor[player:getZoneID()]) < 1 then
        player:startEvent(1503, 0, 1)
        return
    end

    player:startEvent(1503)
end

xi.abyssea.sapper.sapperOnEventUpdate = function(player, csid, option, npc)
    if csid ~= 1503 then
        return
    end

    -- 7949's selection. 6 is "Nothing for now."
    if option >= 0 and option <= 5 then
        player:setCharVar(varPick, option + 1)

        local entry = operations[option]
        player:updateEvent(option, entry.keyItem or 0)
    end
end

xi.abyssea.sapper.sapperOnEventFinish = function(player, csid, option, npc)
    local zoneId = player:getZoneID()

    if csid == 1503 then
        local pick = player:getCharVar(varPick) - 1
        player:setCharVar(varPick, 0)

        -- 7954: 0 Yes, 1 No.
        if pick < 0 or option ~= 0 then
            return
        end

        local questId = xi.abyssea.sapper.questId(pick, zoneId)
        if questId == nil then
            return
        end

        if player:getQuestStatus(xi.questLog.ABYSSEA, questId) ~= xi.questStatus.QUEST_ACCEPTED then
            player:addQuest(xi.questLog.ABYSSEA, questId)
        end

        xi.abyssea.sapper.accept(player, pick)

    elseif csid == 1504 then
        -- 7958: 0 Yes (quit), 1 No (carry on).
        if option ~= 0 then
            return
        end

        local opId = xi.abyssea.sapper.activeOp(player)
        if opId >= 0 then
            local entry = operations[opId]
            for _, ki in ipairs({ entry.keyItem, entry.bottle }) do
                if ki ~= nil and player:hasKeyItem(ki) then
                    player:delKeyItem(ki)
                end
            end
        end

        xi.abyssea.sapper.fail(player)

    elseif csid == 1505 then
        local opId = xi.abyssea.sapper.activeOp(player)
        if opId < 0 then
            return
        end

        local entry   = operations[opId]
        local grade   = xi.abyssea.sapper.grade(player, opId)
        local questId = xi.abyssea.sapper.questId(opId, zoneId)

        for _, ki in ipairs({ entry.keyItem, entry.bottle }) do
            if ki ~= nil and player:hasKeyItem(ki) then
                player:delKeyItem(ki)
            end
        end

        if questId ~= nil then
            player:completeQuest(xi.questLog.ABYSSEA, questId)
            player:addFame(fameFor[zoneId], 30)
        end

        xi.abyssea.sapper.reward(player, opId, grade)
    end
end

-----------------------------------
-- Repair Trunk (Ward Warden I via the hempen sack, Desert Rain I via the flaxen)
--
-- Each zone has one trunk per cargo type, told apart by the sack in their own
-- data[]: the repair-materials trunk carries 1627 and the provisions trunk 1628.
-- Menu (message 8049/8064) in order: 0 examine, 1 pointy, 2 jagged, 3 round,
-- 4 finish cramming.
-----------------------------------
xi.abyssea.sapper.trunkOnTrigger = function(player, npc, cargoKeyItem, csidBase)
    local opId = xi.abyssea.sapper.activeOp(player)

    if
        opId < 0 or
        operations[opId].mechanic ~= sackOp or
        operations[opId].keyItem ~= cargoKeyItem
    then
        return
    end

    player:startEvent(csidBase, cargoKeyItem)
end

xi.abyssea.sapper.trunkOnEventUpdate = function(player, csid, option, npc)
    local opId = xi.abyssea.sapper.activeOp(player)
    if opId < 0 then
        return
    end

    -- 0 examine, 1-3 cram, 4 finish.
    if option == 0 then
        local band = xi.abyssea.sapper.sackCondition(player)
        player:updateEvent(0, band or 5)
    elseif option >= 1 and option <= 3 then
        if xi.abyssea.sapper.cram(player, option) then
            player:updateEvent(option, xi.abyssea.sapper.sackCondition(player) or 5)
        else
            -- Ruptured: the run is over and the sack is gone.
            player:updateEvent(option, 5)
            player:delKeyItem(operations[opId].keyItem)
            xi.abyssea.sapper.fail(player)
        end
    else
        player:updateEvent(4, xi.abyssea.sapper.sackCondition(player) or 5)
    end
end

-----------------------------------
-- Fore / Rear trap (Crimson Carpet II / I)
--
-- Message 7873's menu: 0 nothing, 1 prime, 2 commence, 3 cease, 4 cease other.
-- Priming states the distance; commencing grades the pour five ways.
-----------------------------------
xi.abyssea.sapper.trapOnTrigger = function(player, npc, isRear, csid)
    local opId = xi.abyssea.sapper.activeOp(player)

    if opId < 0 or operations[opId].mechanic ~= trapOp then
        return
    end

    -- Crimson Carpet I is the rear trap, II the fore trap.
    local wantRear = opId == xi.abyssea.sapper.op.CRIMSON_CARPET_I
    if wantRear ~= isRear then
        return
    end

    player:startEvent(csid, isRear and 1 or 0, operations[opId].keyItem)
end

xi.abyssea.sapper.trapOnEventUpdate = function(player, csid, option, npc)
    local opId = xi.abyssea.sapper.activeOp(player)
    if opId < 0 or operations[opId].mechanic ~= trapOp then
        return
    end

    if option == 1 then
        player:updateEvent(0, xi.abyssea.sapper.primeTrap(player, npc))
    elseif option == 2 then
        local band = xi.abyssea.sapper.infuse(player, npc)
        if band == nil then
            return
        end

        player:setCharVar(varGrade, band)
        player:updateEvent(band)
        npcUtil.giveKeyItem(player, operations[opId].bottle)
    elseif option == 3 or option == 4 then
        player:setCharVar(varTrap, 0)
        player:setCharVar(varDist, 0)
        player:updateEvent(0)
    end
end
