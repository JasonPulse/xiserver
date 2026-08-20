-----------------------------------
-- Area: Abyssea - Vunkerl
--  NPC: Rear Trap
-- Involved in Quest: Crimson Carpet I
-----------------------------------
-- Crimson Carpet I infuses the REAR trap, II the FORE trap, each with its own
-- fluid (paralysis 1629 / weakening 1631). Each of the three traps owns its OWN
-- csid, per `xi-dat events 217` -- they are not interchangeable. Infusion
-- logic lives in scripts/globals/abyssea/resistance_sapper.lua.
-----------------------------------
require('scripts/globals/abyssea/resistance_sapper')
-----------------------------------
---@type TNpcEntity
local entity = {}

local traps =
{
    [17666727] = 127,
    [17666728] = 128,
    [17666729] = 129,
}

entity.onTrigger = function(player, npc)
    local csid = traps[npc:getID()]
    if csid == nil then
        return
    end

    xi.abyssea.sapper.trapOnTrigger(player, npc, true, csid)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.abyssea.sapper.trapOnEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
