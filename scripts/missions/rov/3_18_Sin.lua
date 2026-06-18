-----------------------------------
-- Sin
-- Rhapsodies of Vana'diel Mission 3-18
-----------------------------------
-- !addmission 13 184
-- Walk of Echoes zone-in fires CSID 5 (Lady Lilith confronts Lilisette
-- + Cait Sith: "So you finally come... My Spitewardens... Father and
-- Mother both to their knees"). Verified via puppet bridge 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.SIN)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.PENANCE },
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
                return 5
            end,

            onEventFinish =
            {
                [5] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
