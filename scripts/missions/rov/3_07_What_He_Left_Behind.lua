-----------------------------------
-- What He Left Behind
-- Rhapsodies of Vana'diel Mission 3-7
-----------------------------------
-- !addmission 13 158
-- Eastern Adoulin zone-in fires CSID 1549 (Hildebert's apology to Arciela
-- in the council chamber). Verified via puppet bridge 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.WHAT_HE_LEFT_BEHIND)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.GONE_BUT_NOT_FORGOTTEN },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.EASTERN_ADOULIN] =
        {
            onZoneIn = function(player, prevZone)
                return 1549
            end,

            onEventFinish =
            {
                [1549] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
