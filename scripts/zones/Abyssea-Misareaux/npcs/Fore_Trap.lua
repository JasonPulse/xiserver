-----------------------------------
-- Area: Abyssea - Misareaux
--  NPC: Fore Trap
-- Involved in Quest: Crimson Carpet II
-----------------------------------
-- Crimson Carpet I infuses the REAR trap, II the FORE trap, each with its own
-- fluid (paralysis 1629 / weakening 1631). Each of the three traps owns its OWN
-- csid, per `xi-dat events 216` -- they are not interchangeable. Infusion
-- logic lives in scripts/globals/abyssea/resistance_sapper.lua.
-----------------------------------
require('scripts/globals/abyssea/resistance_sapper')
-----------------------------------
---@type TNpcEntity
local entity = {}

local traps =
{
    [17662704] = 124,
    [17662705] = 125,
    [17662706] = 126,
}

entity.onTrigger = function(player, npc)
    local csid = traps[npc:getID()]
    if csid == nil then
        return
    end

    xi.abyssea.sapper.trapOnTrigger(player, npc, false, csid)
end

entity.onEventUpdate = function(player, csid, option, npc)
    xi.abyssea.sapper.trapOnEventUpdate(player, csid, option, npc)
end

entity.onEventFinish = function(player, csid, option, npc)
end

return entity
