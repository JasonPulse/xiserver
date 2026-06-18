-----------------------------------
-- From West to East
-- Rhapsodies of Vana'diel Mission 3-22
-----------------------------------
-- !addmission 13 194
-- Reisenjima — defeat 11 Obstreperous Panopts. Mission completes on
-- the 11th kill directly (used to require a zone-in / trigger area
-- visit after the 11th kill).
-- Obstreperous_Panopt data: pool 5367, family 463, lv121-126, 9999 HP,
-- 32 spawn points, 180s respawn (per ROV_TODO).
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.FROM_WEST_TO_EAST)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.GOOD_THINGS_COME_IN_THREES },
}

local killCounter = function(mob, player, optParams)
    local newCount = mission:getVar(player, 'KillCount') + 1
    if newCount >= 11 then
        mission:setVar(player, 'KillCount', 11)
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
            ['Obstreperous_Panopt'] =
            {
                onMobDeath = killCounter,
            },

            -- Defensive fallback for players who hit 11 before this deploy.
            onZoneIn = function(player, prevZone)
                if mission:getVar(player, 'KillCount') >= 11 then
                    mission:complete(player)
                end
            end,
        },
    },
}

return mission
