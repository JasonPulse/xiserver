-----------------------------------
-- The Brewing Storm
-- Rhapsodies of Vana'diel Mission 3-2
-----------------------------------
-- !addmission 13 150
-- Reisenjima — defeat 3 Perfervid Narakas. Mission completes on the
-- 3rd kill directly (used to require a zone-in / trigger area visit
-- after the 3rd kill, which players occasionally missed).
-- Perfervid_Naraka data: pool 5378, family 472, lv121-126, 9999 HP,
-- 11 spawn points, 180s respawn (per ROV_TODO).
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.THE_BREWING_STORM)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.THE_RIVER_RUNS_RED },
}

local killCounter = function(mob, player, optParams)
    local newCount = mission:getVar(player, 'KillCount') + 1
    if newCount >= 3 then
        mission:setVar(player, 'KillCount', 3)
        mission:complete(player)
    else
        mission:setVar(player, 'KillCount', newCount)
    end
end

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.REISENJIMA] =
        {
            ['Perfervid_Naraka'] =
            {
                onMobDeath = killCounter,
            },

            -- Defensive fallback: if a player hit 3 kills before the
            -- complete-on-kill change was deployed, completing on next
            -- zone-in catches them up.
            onZoneIn = function(player, prevZone)
                if mission:getVar(player, 'KillCount') >= 3 then
                    mission:complete(player)
                end
            end,
        },
    },
}

return mission
