-----------------------------------
-- What Remains of Hope
-- Rhapsodies of Vana'diel Mission 3-15
-----------------------------------
-- !addmission 13 174
-- Walk of Echoes zone-in fires CSID 29 (Cait Sith chastising the player
-- about the masked man absorbing Atomos's power and fleeing, with
-- Lilisette rebuking him in turn). Verified via puppet bridge 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.WHAT_REMAINS_OF_HOPE)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.DEATH_CARES_NOT },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.WALK_OF_ECHOES] =
        {
            onZoneIn = function(player, prevZone)
                return 29
            end,

            onEventFinish =
            {
                [29] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
