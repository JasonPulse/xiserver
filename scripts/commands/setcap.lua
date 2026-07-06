-----------------------------------
-- func: setcap
-- desc: Sets the level cap (genkai / limit-break level) for a TARGET player (by name). For
--       the central GM bot to grant limit-breaks to fleet bots at runtime — bots can't fight
--       Maat at 70, so this is the one grant they can't self-quest. Persistent (setLevelCap
--       writes char_jobs.genkai immediately). The target requests; this GM char grants.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'si',
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!setcap <player> <levelCap>   (1-99)')
end

commandObj.onTrigger = function(player, target, cap)
    -- validate target
    if target == nil then
        error(player, 'You must provide a player name.')
        return
    end

    local targ = GetPlayerByName(target)
    if targ == nil then
        error(player, string.format('Player named "%s" not found (must be online).', target))
        return
    end

    -- validate cap
    if cap == nil or cap < 1 or cap > 99 then
        error(player, 'Invalid cap. Must be 1 to 99.')
        return
    end

    -- grant (persistent: setLevelCap sets jobs.genkai and UPDATEs char_jobs)
    targ:setLevelCap(cap)

    targ:printToPlayer(string.format('Your level cap is now %d.', cap))
    player:printToPlayer(string.format('Set level cap %d for %s.', cap, targ:getName()))
end

return commandObj
