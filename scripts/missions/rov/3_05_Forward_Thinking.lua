-----------------------------------
-- Forward Thinking
-- Rhapsodies of Vana'diel Mission 3-5
-----------------------------------
-- !addmission 13 155
-- Eastern Adoulin zone-in fires CSID 1547 (Arciela's Adoulinian-tomato-
-- juice scene with Ploh Trishbahk). Verified via puppet bridge 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.FORWARD_THINKING)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.TEARS_OF_THE_GENERALS },
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
                return 1547
            end,

            onEventFinish =
            {
                [1547] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
