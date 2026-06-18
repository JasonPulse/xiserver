-----------------------------------
-- Solemnity
-- Rhapsodies of Vana'diel Mission 3-10
-----------------------------------
-- !addmission 13 162
-- Eastern Adoulin zone-in fires CSID 1551 (Fremilla's farcical eulogy
-- for Melvien Castellucci at the council). Verified via puppet bridge
-- 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.SOLEMNITY)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.EYES_ON_YOU },
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
                return 1551
            end,

            onEventFinish =
            {
                [1551] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
