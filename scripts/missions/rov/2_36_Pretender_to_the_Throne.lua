-----------------------------------
-- Pretender to the Throne
-- Rhapsodies of Vana'diel Mission 2-36
-----------------------------------
-- !addmission 13 126
-- Escha - Ru'Aun ??? (battle vs Balamor)
-- Real onMobDeath wired against entity 17961637 (group 95, pool 5631);
-- mission completes when Balamor is defeated rather than on zone-in.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.PRETENDER_TO_THE_THRONE)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.BANISHED },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.ESCHA_RUAUN] =
        {
            ['Balamor'] =
            {
                onMobDeath = function(mob, player, optParams)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
