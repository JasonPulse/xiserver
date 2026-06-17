-----------------------------------
-- Calm After the Storm
-- Rhapsodies of Vana'diel Mission 3-27
-----------------------------------
-- !addmission 13 206
-- Walk of Echoes cutscene-only mission. Zone-in fires CSID 31
-- (614-byte event) on entity 17523350 — verified via xidat per
-- ROV_TODO probable-CSID mapping.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.CALM_AFTER_THE_STORM)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.NARY_A_CLOUD_IN_SIGHT },
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
                return 31
            end,

            onEventFinish =
            {
                [31] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
