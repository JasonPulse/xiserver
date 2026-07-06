-----------------------------------
-- func: grantjob
-- desc: Unlocks a job for a TARGET player (by name). For the central GM bot to grant
--       advanced-job unlocks to fleet bots at runtime (post-login, persistent). Does NOT
--       change the target's current job or level — only sets the unlocked bit (SaveCharJob
--       persists it). The target requests; this GM char grants.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'ss',
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!grantjob <player> <jobID>   (job short-name e.g. PLD, or numeric id)')
end

commandObj.onTrigger = function(player, target, jobArg)
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

    -- validate job (accept short-name or numeric, like !changejob)
    if jobArg == nil then
        error(player, 'You must provide a job short-name (e.g. PLD) or its numeric id.')
        return
    end
    local jobId = tonumber(jobArg) or xi.job[string.upper(jobArg)]
    if jobId == nil or jobId <= 0 or jobId >= xi.MAX_JOB_TYPE then
        error(player, 'Invalid jobID. Use a job short-name (e.g. PLD) or its numeric id.')
        return
    end

    -- grant (persistent: unlockJob sets jobs.unlocked and SaveCharJob writes it)
    targ:unlockJob(jobId)

    local jobNameByNum = {}
    for k, v in pairs(xi.job) do
        jobNameByNum[v] = k
    end
    local name = jobNameByNum[jobId] or tostring(jobId)
    targ:printToPlayer(string.format('Your %s job has been unlocked.', name))
    player:printToPlayer(string.format('Unlocked %s for %s.', name, targ:getName()))
end

return commandObj
