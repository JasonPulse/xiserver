-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Task Delegator
-- Type: Coalition Assignments
--
-- The two Eastern desks, mapped by entity id the same way the Western four are.
-- Their events are 2008 and 2010 and their constant tables carry data[0] = 1 and
-- data[0] = 3, which is Peacekeepers and Scouts, agreeing with bg-wiki's pins of
-- Peacekeepers F-7 and Scouts F-9.
--
-- See scripts/zones/Western_Adoulin/npcs/Task_Delegator.lua for what this
-- replaced, and scripts/globals/coalition_assignments.lua for the engine.
-----------------------------------
require('scripts/globals/coalition_assignments')
-----------------------------------
local ID = zones[xi.zone.EASTERN_ADOULIN]
-----------------------------------
---@type TNpcEntity
local entity = {}

local coalitionByOffset =
{
    [0] = xi.coalition.PEACEKEEPERS, -- F-7, event 2008, data[0] = 1
    [1] = xi.coalition.SCOUTS,       -- F-9, event 2010, data[0] = 3
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
