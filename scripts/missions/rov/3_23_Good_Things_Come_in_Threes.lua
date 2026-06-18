-----------------------------------
-- Good Things Come in Threes
-- Rhapsodies of Vana'diel Mission 3-23
-----------------------------------
-- !addmission 13 196
-- Reisenjima zone-in fires CSID 8 (Iroha's farewell monologue: gentle
-- breeze, the Reckoning, "Never give up", winding the ancient clock).
-- Verified via puppet bridge 2026-06-18 — matches ROV finale arc canon.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.GOOD_THINGS_COME_IN_THREES)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.TACKLING_THE_PROBLEM },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.REISENJIMA] =
        {
            onZoneIn = function(player, prevZone)
                return 8
            end,

            onEventFinish =
            {
                [8] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
