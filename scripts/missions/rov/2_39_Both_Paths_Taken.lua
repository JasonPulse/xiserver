-----------------------------------
-- Both Paths Taken
-- Rhapsodies of Vana'diel Mission 2-39
-----------------------------------
-- !addmission 13 136
-- Transcendental Radiance in Empyreal Paradox.
-- Defeat the Disjoined One. Real onMobDeath wired against entity
-- 16924685 (group 5, pool 7501 added in this same change — pool was
-- missing before, mob_groups.poolId was 0). HP 20000 set on the
-- mob_groups row to match other Empyreal Paradox ROV bosses.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.BOTH_PATHS_TAKEN)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.THE_MAN_BEHIND_THE_MASK },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.EMPYREAL_PARADOX] =
        {
            ['Disjoined_One'] =
            {
                onMobDeath = function(mob, player, optParams)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
