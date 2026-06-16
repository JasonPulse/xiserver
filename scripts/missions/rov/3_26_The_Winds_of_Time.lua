-----------------------------------
-- The Winds of Time
-- Rhapsodies of Vana'diel Mission 3-26
-----------------------------------
-- !addmission 13 202
-- Empyreal Paradox - Defeat Metus.
-- Real onMobDeath wired against entity 16924721 (group 8, pool 4820,
-- lv125 / 20000 HP — pool data verified complete).
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.THE_WINDS_OF_TIME)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.CALM_AFTER_THE_STORM },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.EMPYREAL_PARADOX] =
        {
            ['Metus'] =
            {
                onMobDeath = function(mob, player, optParams)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
