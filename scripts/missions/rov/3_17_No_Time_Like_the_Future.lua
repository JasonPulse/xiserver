-----------------------------------
-- No Time Like the Future
-- Rhapsodies of Vana'diel Mission 3-17
-----------------------------------
-- !addmission 13 180
-- Desuetia - Empyreal Paradox (zone 290, NOT regular Empyreal Paradox).
-- Defeat Sempurne to complete. Real onMobDeath wired against entity
-- 17965057 (group 1, pool 4914, lv125 / 20000 HP).
-- Earlier stub fired in EMPYREAL_PARADOX (zone 36) — that was wrong,
-- Sempurne actually lives in Desuetia-Empyreal Paradox.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.NO_TIME_LIKE_THE_FUTURE)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.SIN },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.DESUETIA_EMPYREAL_PARADOX] =
        {
            ['Sempurne'] =
            {
                onMobDeath = function(mob, player, optParams)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
