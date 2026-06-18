-----------------------------------
-- The Decisive Heroine
-- Rhapsodies of Vana'diel Mission 2-30
-----------------------------------
-- !addmission 13 114
-- Escha - Ru'Aun zone-in fires CSID 4 (Siren Prime + Siren + Iroha
-- Communion: "Where one may falter... Two can succeed... Phoenix, when
-- I am gone, scatter my essence to the skies"). Verified via puppet
-- bridge 2026-06-18. Awards Rhapsody in Emerald.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.THE_DECISIVE_HEROINE)

mission.reward =
{
    keyItem     = xi.ki.RHAPSODY_IN_EMERALD,
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.FALL_FROM_GRACE },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.ESCHA_RUAUN] =
        {
            onZoneIn = function(player, prevZone)
                return 4
            end,

            onEventFinish =
            {
                [4] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
