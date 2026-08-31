-----------------------------------
-- Adoulin Coalition Assignments
--
-- Ninety-five assignments, six Task Delegators, one engine. The spec table is
-- generated into coalition_assignment_data.lua; this file is the machine that
-- runs a row of it.
--
-- HOW RETAIL WORKS, because the shape here is the opposite of what this repo
-- used to assume. An imprimatur is a permit you SPEND, not a reward you earn.
-- bg-wiki "Imprimatur":
--
--   "Imprimaturs are used for participating in any Coalition Assignment. One to
--    three imprimaturs can be utilized per assignment, with increasing rewards
--    and coalition standing rewarded from more imprimaturs."
--   "Imprimaturs are stored with the Task Delegator and a maximum of 15 can be
--    stored."
--   "At first, the regeneration rate for Imprimaturs is one per 3 Earth Hours."
--   "Utilized imprimaturs can also be retrieved if an assignment is cancelled,
--    but will be lost if your total would exceed 15 stored imprimaturs upon
--    retrieval."
--
-- The client says the same thing in its own words, message 7335: "You will have
-- to part with one imprimatur per job you undertake. Each pioneer may possess up
-- to <N> of such permits", and 7340 covers the cancel-and-overflow rule.
--
-- The payout is EXP and Bayld, equal amounts, scaled by how many imprimaturs you
-- spent. bg-wiki heads that column "Rewards: EXP/Bayld" and publishes three
-- figures per assignment which are always base, base x 1.8 and base x 2.4, so
-- the data table stores the base only.
--
-- WHAT THE CLIENT TOLD US, and why the id arithmetic is safe. The six Task
-- Delegators own csids 2007 to 2012 and share one compiled program. Its first
-- instruction is `WkLocal[0] = data[0]`, and data[0] is the only thing that
-- differs between the six copies: 0 Pioneers, 1 Peacekeepers, 2 Couriers,
-- 3 Scouts, 4 Inventors, 5 Mummers. The program then branches on WkLocal[0] to
-- that coalition's own assignment list. Message 7373 prints the list in full,
-- nineteen zone rows in a fixed order, and that order is the zoneSlot column in
-- the spec. The constant pool carries each Gather and Analyze turn-in item
-- beside its slot, and both runs match bg-wiki zone for zone AND match this
-- repo's declared id order exactly. That is the check that makes it safe to
-- treat the declared ids as verb-major, zone-slot-minor.
--
-- THREE FAMILIES ARE DECLARED BUT CANNOT BE OFFERED. They are listed by
-- xi.coalitionAssignments.blockedReason and the Task Delegator hides them
-- rather than handing out an assignment that can never close.
--
--   Provide (ids 16 to 20) is retired ON RETAIL. bg-wiki: "It is no longer
--   possible to complete Base Provision assignments... available only if the
--   frontier station in that area is NOT established", and every station is
--   built. Nothing to implement; not offering them IS the retail behaviour.
--
--   Preserve (ids 64 to 72) needs Lair Reives, which this server does not have
--   in any form. Colonization Reives exist (globals/colonization_reives.lua)
--   and Wildskeeper Reives exist; the lair kind has no data, no mobs and no
--   spawner. Building it is its own system.
--
--   Procure (ids 0 to 7) needs harvesting, logging and mining points in the
--   Ulbuka zones. The NPCs are in npc_list and the HELM engine already calls
--   xi.helm.result on every attempt, which is the hook this file uses, but
--   globals/hobbies/helm/data.lua has no drop table or point list for any
--   Ulbuka zone (Yahse Hunting Grounds is present and its two tables read
--   "-- TODO"). The moment that data lands, Procure closes with no change here.
--
-- ONE ACTIVE ASSIGNMENT PER COALITION. Each Task Delegator serves exactly one
-- coalition and the accept, report and cancel menus are all that coalition's
-- own list, so the working state is one slot per coalition rather than a queue.
--
-- THE FAME CURVE IS OURS. Client message 7420 shows "Personal fame acquired:
-- <n> pts. Total personal fame: <n> pts." and 7506 names the eight standing
-- tiers, Petitioner through Legend, so the mechanism is retail and the tier
-- names are the client's. What nobody publishes is the points per tier, so
-- rankThresholds below is tuning, in the same spirit as the cruor band in
-- abyssea/resistance_sapper.lua. Fame gained is the imprimaturs spent, which is
-- retail: "increasing rewards and coalition standing... from more imprimaturs".
-----------------------------------
require('scripts/globals/coalition')
require('scripts/globals/coalition_assignment_data')
require('scripts/globals/hobbies/helm/data')
require('scripts/globals/npc_util')
-----------------------------------

xi = xi or {}
xi.coalitionAssignments = xi.coalitionAssignments or {}

local assignments = xi.coalitionAssignments

-- bg-wiki: base storage is 15, and the mattock cordons raise it to 16 and 18.
-- Those key items are not granted anywhere on this server yet, so the cap is
-- the base one until they are.
assignments.maxStored = 15

-- bg-wiki, after the October 2025 update: "Imprimaturs refresh in half the time
-- (from original base time of 6 hours per imprimatur to 3 hours)." The client
-- carries the same figure and the three cordon rates beside it, as the seconds
-- 10800, 9000, 7200 and 5400 in the Task Delegator's own constant pool.
assignments.accrualSeconds = 10800

-- bg-wiki: "One to three imprimaturs can be utilized per assignment." The
-- client's own menu (7360) lists five, but only three are ever priced, so three
-- is the ceiling and the fourth and fifth rows are never offered.
assignments.maxSpend = 3

-- Multiplier on the assignment's base EXP and Bayld, by imprimaturs spent.
assignments.rewardScale = { 1.0, 1.8, 2.4 }

-- Total personal fame needed to hold each standing tier. See the header: the
-- tier names are the client's, the numbers are ours.
assignments.rankThresholds = { 0, 15, 40, 80, 140, 220, 330, 480 }

local varLastTick = 'Coalition_Imp_Tick'

local function varJob(coalition)
    return string.format('Coalition_Job_%d', coalition)
end

local function varSpent(coalition)
    return string.format('Coalition_JobImp_%d', coalition)
end

local function varProgress(coalition)
    return string.format('Coalition_JobPrg_%d', coalition)
end

local function varFame(coalition)
    return string.format('Coalition_Fame_%d', coalition)
end

-----------------------------------
-- Spec lookup
-----------------------------------

--- The spec row for a quest id, or nil if that id is not an assignment.
assignments.get = function(questId)
    return assignments.spec[questId]
end

--- The coalition an assignment belongs to.
assignments.coalitionOf = function(questId)
    local entry = assignments.spec[questId]
    if entry == nil then
        return nil
    end

    return assignments.kindInfo[entry.kind].coalition
end

--- Why this assignment can never be offered, or nil if it can. See the header
--- for what each reason means.
assignments.blockedReason = function(questId)
    local entry = assignments.spec[questId]
    if entry == nil then
        return 'unknown'
    end

    if entry.retired then
        return 'retired'
    end

    if entry.reive == assignments.reive.LAIR then
        return 'no-lair-reives'
    end

    if entry.helm ~= nil then
        local zoneTable = xi.helm.dataTable[entry.helm].zone[assignments.zoneForSlot[entry.slot]]
        if
            zoneTable == nil or
            #zoneTable.points == 0
        then
            return 'no-gathering-points'
        end
    end

    return nil
end

--- Both zones an assignment counts in. bg-wiki gives several of them a second
--- zone ("either Ceizak Battlegrounds or Yahse Hunting Grounds") and the client
--- says the same in its "Alternatively, the objective may also be completed
--- in..." lines.
assignments.zonesFor = function(questId)
    local entry = assignments.spec[questId]
    if entry == nil then
        return {}
    end

    local zones = { assignments.zoneForSlot[entry.slot] }
    if entry.alt ~= nil then
        table.insert(zones, assignments.zoneForSlot[entry.alt])
    end

    return zones
end

--- True if the assignment's objective can be worked in this zone.
assignments.countsInZone = function(questId, zoneId)
    for _, id in ipairs(assignments.zonesFor(questId)) do
        if id == zoneId then
            return true
        end
    end

    return false
end

-----------------------------------
-- Standing
-----------------------------------

assignments.getFame = function(player, coalition)
    return player:getCharVar(varFame(coalition))
end

--- Standing tier 1 to 8 for the fame held, per rankThresholds.
assignments.rankForFame = function(fame)
    local tier = 1
    for index, needed in ipairs(assignments.rankThresholds) do
        if fame >= needed then
            tier = index
        end
    end

    return tier
end

--- The player's standing in one coalition, or 0 when not registered at all.
--- Registration is what puts a non-zero rank on the CharVar the colonization
--- packet reads, so an unregistered player has no standing to compare.
assignments.rankOf = function(player, coalition)
    if xi.coalition.getRank(player, coalition) == 0 then
        return 0
    end

    return assignments.rankForFame(assignments.getFame(player, coalition))
end

--- Add fame and push the resulting tier onto the rank CharVar the colonization
--- packet reads. Returns the new tier and whether it went up.
assignments.addFame = function(player, coalition, amount)
    local before = assignments.rankOf(player, coalition)

    player:incrementCharVar(varFame(coalition), amount)

    local after = assignments.rankForFame(assignments.getFame(player, coalition))
    xi.coalition.setRank(player, coalition, after)

    return after, after > before
end

-----------------------------------
-- Imprimaturs
--
-- The balance itself lives in char_points.imprimaturs, which is what
-- xi.coalition.getImprimatursBalance reads. This layer only adds the retail
-- accrual on top: one per accrualSeconds, capped, and banked against a
-- timestamp so it keeps ticking while the player is offline.
-----------------------------------

--- Credit whatever has accrued since the last tick. Safe to call as often as
--- you like; it only ever moves the clock forward by whole intervals it paid
--- for, so no fraction of an interval is lost or double counted.
assignments.accrue = function(player)
    local now  = GetSystemTime()
    local last = player:getCharVar(varLastTick)

    if last == 0 then
        player:setCharVar(varLastTick, now)
        return
    end

    local held = xi.coalition.getImprimatursBalance(player)
    if held >= assignments.maxStored then
        -- At the cap the clock does not bank anything. Client message 7355:
        -- "If you do not use them before the next distribution, you will not
        -- receive any additional ones."
        player:setCharVar(varLastTick, now)
        return
    end

    local earned = math.floor((now - last) / assignments.accrualSeconds)
    if earned <= 0 then
        return
    end

    local room = assignments.maxStored - held
    local paid = math.min(earned, room)

    xi.coalition.addImprimatursBalance(player, paid)
    player:setCharVar(varLastTick, last + paid * assignments.accrualSeconds)
end

--- Current balance, after crediting anything owed.
assignments.imprimaturs = function(player)
    assignments.accrue(player)

    return xi.coalition.getImprimatursBalance(player)
end

--- Seconds until the next imprimatur, or 0 when the player is at the cap.
assignments.nextAccrualIn = function(player)
    assignments.accrue(player)

    if xi.coalition.getImprimatursBalance(player) >= assignments.maxStored then
        return 0
    end

    local elapsed = GetSystemTime() - player:getCharVar(varLastTick)

    return math.max(0, assignments.accrualSeconds - elapsed)
end

--- Hand imprimaturs back, destroying anything over the cap. Client message
--- 7340 spells the loss out.
assignments.refund = function(player, amount)
    local held = xi.coalition.getImprimatursBalance(player)
    local room = assignments.maxStored - held
    local paid = math.max(0, math.min(amount, room))

    if paid > 0 then
        xi.coalition.addImprimatursBalance(player, paid)
    end

    return paid
end

-----------------------------------
-- The active assignment
-----------------------------------

--- The quest id this player is running for a coalition, or nil.
assignments.active = function(player, coalition)
    local stored = player:getCharVar(varJob(coalition))
    if stored == 0 then
        return nil
    end

    return stored - 1
end

assignments.spentOn = function(player, coalition)
    return player:getCharVar(varSpent(coalition))
end

assignments.progressOf = function(player, coalition)
    return player:getCharVar(varProgress(coalition))
end

--- How many steps this assignment needs. Everything that is not counted in
--- multiples takes a single step.
assignments.goalFor = function(questId)
    local entry = assignments.spec[questId]
    if entry == nil then
        return 1
    end

    return entry.count or 1
end

--- True once the active assignment's objective is met and it can be reported.
assignments.isReady = function(player, coalition)
    local questId = assignments.active(player, coalition)
    if questId == nil then
        return false
    end

    return assignments.progressOf(player, coalition) >= assignments.goalFor(questId)
end

local function clearSlot(player, coalition)
    player:setCharVar(varJob(coalition), 0)
    player:setCharVar(varSpent(coalition), 0)
    player:setCharVar(varProgress(coalition), 0)
end

--- Every assignment this player could accept from one coalition right now,
--- in the client's own list order.
assignments.offerable = function(player, coalition, typeIndex)
    local out  = {}
    local rank = assignments.rankOf(player, coalition)

    if rank == 0 then
        return out
    end

    for questId = 0, 95 do
        local entry = assignments.spec[questId]
        if entry ~= nil then
            local info = assignments.kindInfo[entry.kind]
            if
                info.coalition == coalition and
                (typeIndex == nil or info.typeIndex == typeIndex) and
                entry.rank <= rank and
                assignments.blockedReason(questId) == nil
            then
                table.insert(out, questId)
            end
        end
    end

    return out
end

--- Take on an assignment, spending imprimaturs. Returns true, or false plus a
--- reason: 'busy', 'blocked', 'rank', 'imprimaturs'.
assignments.accept = function(player, questId, spend)
    local entry = assignments.spec[questId]
    if entry == nil then
        return false, 'blocked'
    end

    local coalition = assignments.kindInfo[entry.kind].coalition

    if assignments.active(player, coalition) ~= nil then
        return false, 'busy'
    end

    if assignments.blockedReason(questId) ~= nil then
        return false, 'blocked'
    end

    if assignments.rankOf(player, coalition) < entry.rank then
        return false, 'rank'
    end

    local cost = math.max(1, math.min(spend or 1, assignments.maxSpend))
    if assignments.imprimaturs(player) < cost then
        return false, 'imprimaturs'
    end

    -- Spending here is a real debit of the balance. It does NOT touch the
    -- lifetime-spent counter, which xi.coalition.spendImprimaturs would bump;
    -- that counter gates SOA missions and tracks edification, and an assignment
    -- that is later cancelled refunds the permit, so it must not count.
    player:delCurrency('imprimaturs', cost)

    player:setCharVar(varJob(coalition), questId + 1)
    player:setCharVar(varSpent(coalition), cost)
    player:setCharVar(varProgress(coalition), 0)

    if player:getQuestStatus(xi.questLog.COALITION, questId) ~= xi.questStatus.QUEST_ACCEPTED then
        player:addQuest(xi.questLog.COALITION, questId)
    end

    return true
end

--- Give the assignment up. The permit comes back, capped. Returns the number
--- of imprimaturs actually restored, or nil if nothing was running.
assignments.cancel = function(player, coalition)
    local questId = assignments.active(player, coalition)
    if questId == nil then
        return nil
    end

    local restored = assignments.refund(player, assignments.spentOn(player, coalition))

    clearSlot(player, coalition)
    player:delQuest(xi.questLog.COALITION, questId)

    return restored
end

--- Pay an assignment out. Returns true plus the EXP/Bayld figure and the new
--- standing tier, or false when it is not finished.
assignments.report = function(player, coalition)
    local questId = assignments.active(player, coalition)
    if
        questId == nil or
        not assignments.isReady(player, coalition)
    then
        return false
    end

    local entry = assignments.spec[questId]
    local spent = math.max(1, math.min(assignments.spentOn(player, coalition), assignments.maxSpend))
    local payout = math.floor(entry.reward * assignments.rewardScale[spent])

    player:addExp(payout)
    player:addCurrency('bayld', payout)

    -- The permit is only truly spent once the assignment closes, because a
    -- cancel hands it back. Bumping the lifetime-spent counter here rather than
    -- at accept is what keeps the SOA mission gates that read it honest, and it
    -- is what replaces Task_Delegator's old daily trickle.
    xi.coalition.addImprimatursSpent(player, spent)

    local tier, wentUp = assignments.addFame(player, coalition, spent)

    clearSlot(player, coalition)
    player:completeQuest(xi.questLog.COALITION, questId)

    return true, payout, tier, wentUp
end

-----------------------------------
-- Objective hooks
--
-- Every kind reports progress through one of these. They all take the player
-- first and all no-op quietly when nothing is running, so they are safe to wire
-- into hot paths like mob death.
-----------------------------------

--- Bump the running assignment of `kind` if the player is in a zone it counts
--- in and `predicate` accepts its spec row. Returns true when this step
--- finished the objective.
local function advance(player, kind, predicate, amount)
    local coalition = assignments.kindInfo[kind].coalition
    local questId   = assignments.active(player, coalition)

    if questId == nil then
        return false
    end

    local entry = assignments.spec[questId]
    if
        entry.kind ~= kind or
        not assignments.countsInZone(questId, player:getZoneID())
    then
        return false
    end

    if
        predicate ~= nil and
        not predicate(entry)
    then
        return false
    end

    local goal = assignments.goalFor(questId)
    if assignments.progressOf(player, coalition) >= goal then
        return false
    end

    local now = math.min(goal, assignments.progressOf(player, coalition) + (amount or 1))
    player:setCharVar(varProgress(coalition), now)

    return now >= goal
end

--- Procure. Called from xi.helm.result for every successful gathering attempt.
--- Client message 7376: "Only materials gathered in the field are valid."
assignments.onHelmSuccess = function(player, helmType)
    return advance(player, assignments.kind.PROCURE, function(entry)
        return entry.helm == helmType
    end)
end

--- Patrol. Called for every mob death the player gets credit for.
assignments.onMobKill = function(player, family)
    return advance(player, assignments.kind.PATROL, function(entry)
        return entry.family == family
    end)
end

--- Research. Called when a mob lands a TP move on the player. Client message
--- 7414: "become the victim of a special attack from <creature>".
assignments.onWeaponskillTaken = function(player, family)
    return advance(player, assignments.kind.RESEARCH, function(entry)
        return entry.family == family
    end)
end

--- Boost. Called when the player cheers a frontier station worker.
assignments.onCheerWorker = function(player)
    return advance(player, assignments.kind.BOOST, nil)
end

--- Survey, Recover, Support and Deliver all turn on touching one field entity,
--- so they share this. Returns true when the touch closed the objective, false
--- when the player has no matching assignment here.
assignments.onFieldTrigger = function(player, kind)
    return advance(player, kind, nil)
end

--- Gather and Analyze. Called when the player trades to a Task Delegator.
--- Client message 7401: "The method of procuring the items does not matter."
--- Returns true when the trade was the right one and was taken.
assignments.onTurnIn = function(player, coalition, trade)
    local questId = assignments.active(player, coalition)
    if questId == nil then
        return false
    end

    local entry = assignments.spec[questId]
    if entry.item == nil then
        return false
    end

    local wanted = entry.count or 1
    if not trade:hasItemQty(entry.item, wanted) then
        return false
    end

    player:tradeComplete()
    player:setCharVar(varProgress(coalition), wanted)

    return true
end

-----------------------------------
-- Field entities
--
-- Four assignment families turn on touching one thing out in Ulbuka, and the
-- entities are already in npc_list under the names retail uses:
--
--     Survey   Ergon_Locus              client message 7399
--     Recover  Lost_Article             client message 7412
--     Support  Bivouac#N_Administrator  client message 7393
--     Deliver  Station_Administrator    client message 7392
--
-- Boost is the odd one out: message 7417 says to cheer the staff, so it runs off
-- the emote hook rather than a trigger, and Station_Worker has no handler here.
--
-- Deliver is also the only one that can be undone. Message 7395: "the supplies
-- are quite fragile, so you must avoid waypoints to ensure that they do not
-- break", and 7323 is the delegator refusing a broken one. onWaypointUse below
-- is what enforces that.
-----------------------------------

local fieldLines =
{
    [assignments.kind.SURVEY] =
    {
        done = 'You survey the ergon locus and record what the land gives up.',
        idle = 'Arcane energies wash over the locus. Nothing here concerns you.',
    },

    [assignments.kind.RECOVER] =
    {
        done = 'You recover the article a pioneer lost here.',
        idle = 'Something was dropped here once. It is no longer your concern.',
    },

    [assignments.kind.SUPPORT] =
    {
        done = 'You hand the supplies over to the bivouac.',
        idle = 'The bivouac is well stocked and needs nothing from you.',
    },

    [assignments.kind.DELIVER] =
    {
        done = 'The station hands you the supplies. Carry them back to the assignment desk, and keep clear of waypoints.',
        idle = 'The station has no consignment waiting for you.',
    },
}

--- Shared onTrigger for the four field entities. Says what happened either way,
--- because a silent NPC reads as a broken one.
assignments.fieldNpc = function(player, kind)
    local lines = fieldLines[kind]

    if assignments.onFieldTrigger(player, kind) then
        player:printToPlayer(lines.done, xi.msg.channel.NS_SAY)

        return true
    end

    player:printToPlayer(lines.idle, xi.msg.channel.NS_SAY)

    return false
end

-- How close the player must stand to the frontier station worker for a cheer to
-- reach them. The same six yalms the game uses for a normal NPC conversation.
local cheerRange = 6

--- Boost. Client message 7417: "head to the frontier station in <zone> and cheer
--- up the staff located there." The emote hook does not say who was cheered, so
--- the worker is found by proximity, which is also what makes a cheer thrown
--- from across the zone not count.
assignments.onCheer = function(player)
    local zoneTable = zones[player:getZoneID()]
    if
        zoneTable == nil or
        zoneTable.npc == nil or
        zoneTable.npc.STATION_WORKER == nil
    then
        return false
    end

    local worker = GetNPCByID(zoneTable.npc.STATION_WORKER)
    if
        worker == nil or
        player:checkDistance(worker) > cheerRange
    then
        return false
    end

    if not assignments.onCheerWorker(player) then
        return false
    end

    player:printToPlayer('The worker brightens. Report back when you can.', xi.msg.channel.NS_SAY)

    return true
end

--- Message 7395: a waypoint breaks a Supply Delivery consignment. The
--- assignment survives, the progress does not, so the player walks back to the
--- frontier station for another load.
assignments.onWaypointUse = function(player)
    local coalition = assignments.kindInfo[assignments.kind.DELIVER].coalition
    local questId   = assignments.active(player, coalition)

    if
        questId == nil or
        assignments.spec[questId].kind ~= assignments.kind.DELIVER or
        assignments.progressOf(player, coalition) == 0
    then
        return false
    end

    player:setCharVar(varProgress(coalition), 0)
    player:printToPlayer(
        'The supplies did not survive the waypoint. Return to the frontier station for another consignment.',
        xi.msg.channel.NS_SAY)

    return true
end

-----------------------------------
-- The Task Delegator
--
-- WHAT IS DECODED, AND WHAT IS NOT. Everything about the event tree below was
-- read out of the client, not guessed. The six delegators own one event each:
--
--     2007  Pioneers      Western Adoulin  17825848   data[0] = 0
--     2008  Peacekeepers  Eastern Adoulin  17829944   data[0] = 1
--     2009  Couriers      Western Adoulin  17825849   data[0] = 2
--     2010  Scouts        Eastern Adoulin  17829945   data[0] = 3
--     2011  Inventors     Western Adoulin  17825850   data[0] = 4
--     2012  Mummers       Western Adoulin  17825851   data[0] = 5
--
-- and the coalition each one serves is settled three ways that agree: data[0],
-- the branch ladder the program runs on WkLocal[0], and bg-wiki's own map
-- pins (Pioneers E-8, Couriers G-7, Mummers G-11, Inventors J-10 in Western
-- Adoulin; Peacekeepers F-7 and Scouts F-9 in Eastern). The program's first
-- instruction is `WkLocal[0] = data[0]`, so it selects its own coalition and
-- the server does not have to tell it which one it is.
--
-- Every menu below is the client's own, and its option order is read from the
-- Selection Dialog text of the message named beside it. The MENU opcodes all
-- carry a literal zero option bitmask, so no unverified mask is being supplied
-- and the windows render with every row enabled.
--
-- WHAT IS NOT SETTLED is the work-var handshake: after each menu the program
-- reads WkZone[0], which is updateEvent parameter 0, and the meaning of that
-- value per stage cannot be established offline. Menus also cannot be driven or
-- observed from the agent bridge, because injecting an outgoing 0x05B tells the
-- server what was picked without advancing the client's own event program.
--
-- So this is built FAIL-SAFE rather than optimistic: the update handler only
-- records the player's choices in local vars, and nothing is spent, granted,
-- paid or cleared until onEventFinish. If a stage stalls because parameter 0
-- was not what the program wanted, the player releases and loses nothing: no
-- imprimatur has moved and no assignment has changed. The one thing that needs
-- a human at a screen is confirming the handshake; the failure mode until then
-- is a menu that does not advance, never a corrupted assignment.
-----------------------------------

assignments.delegator = {}

-- Coalition to the csid that coalition's Task Delegator owns.
assignments.delegator.csid =
{
    [xi.coalition.PIONEERS]     = 2007,
    [xi.coalition.PEACEKEEPERS] = 2008,
    [xi.coalition.COURIERS]     = 2009,
    [xi.coalition.SCOUTS]       = 2010,
    [xi.coalition.INVENTORS]    = 2011,
    [xi.coalition.MUMMERS]      = 2012,
}

-- How many assignment types each coalition's type menu lists, which is what
-- makes the stage counter below able to tell one menu from the next.
assignments.delegator.typeCount =
{
    [xi.coalition.PIONEERS]     = 2, -- 7372 Procure materials, Clear the way
    [xi.coalition.PEACEKEEPERS] = 2, -- 7380 Preserve the peace, Patrol
    [xi.coalition.COURIERS]     = 3, -- 7387 Base provisions, Supply delivery, Frontline support
    [xi.coalition.SCOUTS]       = 2, -- 7396 Land surveys, Component analyses
    [xi.coalition.INVENTORS]    = 1, -- 7404 Gather materials
    [xi.coalition.MUMMERS]      = 3, -- 7408 Recovering lost articles, Behavioral research, Morale boosting
}

-- Message 7348's rows, in order.
local menuMode =
{
    UNDERTAKE = 0,
    REPORT    = 1,
    CANCEL    = 2,
    TIME      = 3,
    EXPLAIN   = 4,
    LEAVE     = 5,
}

local varStage = 'CoalStage'
local varMode  = 'CoalMode'
local varType  = 'CoalType'
local varPick  = 'CoalPick'
local varSpend = 'CoalSpend'

local function resetFlow(player)
    for _, name in ipairs({ varStage, varMode, varType, varPick, varSpend }) do
        player:setLocalVar(name, 0)
    end
end

--- Talk to a Task Delegator. Credits any imprimaturs owed first, because the
--- main menu prints the balance.
assignments.delegator.onTrigger = function(player, coalition)
    assignments.accrue(player)
    resetFlow(player)

    player:startEvent(assignments.delegator.csid[coalition])
end

--- Trade to a Task Delegator. Only Gather and Analyze turn in through a trade;
--- client message 7401 says "Simply bringing the items to the assignment desk
--- will serve as your report", so the trade both completes and reports.
assignments.delegator.onTrade = function(player, coalition, trade)
    if not assignments.onTurnIn(player, coalition, trade) then
        return false
    end

    local ok, payout, tier, wentUp = assignments.report(player, coalition)
    if ok then
        assignments.delegator.announce(player, coalition, payout, tier, wentUp)
    end

    return true
end

--- The reward lines. These are the client's own wording from messages 7362,
--- 7367 and 7506, said through the chat log because the reward beat sits behind
--- the same unverified handshake as the rest of the tree.
assignments.delegator.announce = function(player, coalition, payout, tier, wentUp)
    player:printToPlayer(string.format(
        'Your report was quite valuable. Thank you. You receive %d experience points and %d bayld.',
        payout, payout), xi.msg.channel.NS_SAY)

    if wentUp then
        player:printToPlayer(string.format(
            '%s %s!',
            xi.coalition.displayNames[coalition], assignments.rankNames[tier]), xi.msg.channel.NS_SAY)
    end
end

--- Which stage of the flow an update belongs to. The client sends one update
--- per menu, so counting them is what tells 'this option is a zone slot' from
--- 'this option is an imprimatur count'.
assignments.delegator.onEventUpdate = function(player, csid, option, coalition)
    if csid ~= assignments.delegator.csid[coalition] then
        return
    end

    local stage = player:getLocalVar(varStage)

    if stage == 0 then
        -- Message 7348, the main menu.
        player:setLocalVar(varMode, option)
        player:setLocalVar(varStage, 1)

        if option == menuMode.TIME then
            local seconds = assignments.nextAccrualIn(player)
            -- 7354 renders minutes; 7353 renders the holding.
            player:updateEvent(math.floor(seconds / 60), assignments.imprimaturs(player))
            return
        end

        if
            option == menuMode.EXPLAIN or
            option == menuMode.LEAVE
        then
            player:updateEvent(0)
            return
        end

        player:updateEvent(option)

    elseif stage == 1 then
        -- The coalition's type menu. Its last row is "None of the above."
        if option >= assignments.delegator.typeCount[coalition] then
            resetFlow(player)
            player:updateEvent(0)
            return
        end

        player:setLocalVar(varType, option + 1)
        player:setLocalVar(varStage, 2)
        player:updateEvent(player:getLocalVar(varMode))

    elseif stage == 2 then
        -- The assignment list. Rows 0 to 18 are zone slots, 19 is Cancel.
        local questId = assignments.delegator.questAt(player, coalition, option)
        if questId == nil then
            resetFlow(player)
            player:updateEvent(0)
            return
        end

        player:setLocalVar(varPick, questId + 1)

        if player:getLocalVar(varMode) == menuMode.UNDERTAKE then
            player:setLocalVar(varStage, 3)
            player:updateEvent(assignments.imprimaturs(player))
            return
        end

        -- Report and cancel have nothing more to ask.
        player:setLocalVar(varStage, 4)
        player:updateEvent(0)

    elseif stage == 3 then
        -- Message 7360, "How many will you use?". Rows 0 to 4 are one to five;
        -- only the first three are ever priced, and row 5 backs out.
        if option >= assignments.maxSpend then
            resetFlow(player)
            player:updateEvent(0)
            return
        end

        player:setLocalVar(varSpend, option + 1)
        player:setLocalVar(varStage, 4)
        player:updateEvent(option + 1)

    else
        player:updateEvent(0)
    end
end

--- The quest id sitting on row `option` of the assignment list, or nil when the
--- row is one this coalition does not fill or the player cannot take.
assignments.delegator.questAt = function(player, coalition, option)
    if option > 18 then
        return nil
    end

    -- varType holds the type index the way kindInfo does, one based, which is
    -- the menu row plus one.
    local typeIndex = player:getLocalVar(varType)
    if typeIndex < 1 then
        return nil
    end

    for _, questId in ipairs(assignments.offerable(player, coalition, typeIndex)) do
        if assignments.spec[questId].slot == option then
            return questId
        end
    end

    -- Report and cancel act on what is already running, whatever its rank.
    local running = assignments.active(player, coalition)
    if
        running ~= nil and
        assignments.spec[running].slot == option
    then
        return running
    end

    return nil
end

--- Commit whatever the player chose. Everything that costs or pays happens
--- here and nowhere else, so an abandoned event is a no-op.
assignments.delegator.onEventFinish = function(player, csid, option, coalition)
    if csid ~= assignments.delegator.csid[coalition] then
        return
    end

    local mode    = player:getLocalVar(varMode)
    local questId = player:getLocalVar(varPick) - 1
    local spend   = player:getLocalVar(varSpend)

    resetFlow(player)

    if mode == menuMode.UNDERTAKE then
        if
            questId < 0 or
            spend <= 0
        then
            return
        end

        local ok, reason = assignments.accept(player, questId, spend)
        if not ok then
            assignments.delegator.refuse(player, reason)
            return
        end

        player:printToPlayer(string.format(
            'You used %d imprimatur%s, and currently have a stock of %d.',
            spend, spend == 1 and '' or 's',
            assignments.imprimaturs(player)), xi.msg.channel.NS_SAY)

    elseif mode == menuMode.REPORT then
        local ok, payout, tier, wentUp = assignments.report(player, coalition)
        if ok then
            assignments.delegator.announce(player, coalition, payout, tier, wentUp)
        end

    elseif mode == menuMode.CANCEL then
        local restored = assignments.cancel(player, coalition)
        if restored ~= nil then
            -- Client message 7352 plus 7353.
            player:printToPlayer(string.format(
                'Your cancellation is filed. You hold %d imprimatur%s.',
                assignments.imprimaturs(player),
                assignments.imprimaturs(player) == 1 and '' or 's'), xi.msg.channel.NS_SAY)
        end
    end
end

--- Say why an accept was refused, in the client's own terms where it has them.
assignments.delegator.refuse = function(player, reason)
    local lines =
    {
        busy         = 'You are already working on an assignment for this coalition.',
        rank         = 'I am only authorized to give tasks to those with the appropriate credentials.',
        imprimaturs  = 'What is this, then? You do not have enough imprimaturs.',
        blocked      = 'Unfortunately, we do not currently have any assignments for you to undertake.',
    }

    player:printToPlayer(lines[reason] or lines.blocked, xi.msg.channel.NS_SAY)
end

return assignments
