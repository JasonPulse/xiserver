-----------------------------------
-- Area: Western Adoulin
--  NPC: Task Delegator
-- Type: Coalition Assignments
--
-- Four of the six delegators stand in Western Adoulin and one script serves all
-- four, because the server keys a zone script by NPC name. Which coalition a
-- given desk belongs to is settled by its entity id, and that mapping is the
-- client's own: each delegator owns one event whose constant table begins
-- `WkLocal[0] = data[0]`, and data[0] is the coalition index. Reading the four
-- Western desks in id order gives 0, 2, 4, 5, which is Pioneers, Couriers,
-- Inventors and Mummers, and that agrees with bg-wiki's map pins (Pioneers E-8,
-- Couriers G-7, Mummers G-11, Inventors J-10).
--
-- The engine is scripts/globals/coalition_assignments.lua. Read its header for
-- how the assignment economy works and what is still unverified about the event
-- handshake.
--
-- WHAT THIS FILE REPLACED. The previous version paid a flat 100 imprimaturs
-- once a Vana'diel day and bumped the lifetime-spent counter by 10, as a
-- stand-in for assignments that did not exist. Both are gone: imprimaturs now
-- accrue on retail's own timer and the spent counter moves when an assignment
-- is reported. The old edification path is gone too, and deliberately: it
-- advanced the same per-coalition rank CharVar that personal standing now
-- drives, so leaving it in would have let the two fight over one value. On
-- retail those are different axes, personal fame against coalition expansion
-- (client messages 7420 and 7421).
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
local ID = zones[xi.zone.WESTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local coalitionByOffset =
{
    [0] = xi.coalition.PIONEERS,  -- E-8,  event 2007, data[0] = 0
    [1] = xi.coalition.COURIERS,  -- G-7,  event 2009, data[0] = 2
    [2] = xi.coalition.INVENTORS, -- J-10, event 2011, data[0] = 4
    [3] = xi.coalition.MUMMERS,   -- G-11, event 2012, data[0] = 5
}

local function coalitionOf(npc)
    return coalitionByOffset[npc:getID() - ID.npc.TASK_DELEGATOR_OFFSET]
end

entity.onTrade = function(player, npc, trade)
    local coalition = coalitionOf(npc)
    if coalition == nil then
        return
    end

    xi.coalitionAssignments.delegator.onTrade(player, coalition, trade)
end

entity.onTrigger = function(player, npc)
    local coalition = coalitionOf(npc)
    if coalition == nil then
        return
    end

    xi.coalitionAssignments.delegator.onTrigger(player, coalition)
end

entity.onEventUpdate = function(player, csid, option, npc)
    local coalition = coalitionOf(npc)
    if coalition == nil then
        return
    end

    xi.coalitionAssignments.delegator.onEventUpdate(player, csid, option, coalition)
end

entity.onEventFinish = function(player, csid, option, npc)
    local coalition = coalitionOf(npc)
    if coalition == nil then
        return
    end

    xi.coalitionAssignments.delegator.onEventFinish(player, csid, option, coalition)
end

return entity
