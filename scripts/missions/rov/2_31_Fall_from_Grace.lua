-----------------------------------
-- Fall from Grace
-- Rhapsodies of Vana'diel Mission 2-31
-----------------------------------
-- !addmission 13 116
-- Shattered Telepoint (Konschtat) : !pos 135 19 220 108
-- Shattered Telepoint (La Theine) : !pos 334 19 -60 102
-- Shattered Telepoint (Tahrongi)  : !pos 179 35 255 117
-- CSID 6 fires the Iroha "Ah, Master. Come! To the world of the gods!"
-- cutscene on Shattered Telepoint trigger. Verified via puppet bridge
-- 2026-06-18 — content matches Fall from Grace's Al'Taieu setup.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.FALL_FROM_GRACE)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.BANISHING_THE_DARKNESS },
}

local function onFinish(player, csid, option, npc)
    mission:complete(player)
end

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.KONSCHTAT_HIGHLANDS] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(6),
            },
            onEventFinish = { [6] = onFinish },
        },

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(6),
            },
            onEventFinish = { [6] = onFinish },
        },

        [xi.zone.TAHRONGI_CANYON] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(6),
            },
            onEventFinish = { [6] = onFinish },
        },
    },
}

return mission
