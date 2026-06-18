-----------------------------------
-- Call of the Void
-- Rhapsodies of Vana'diel Mission 2-38
-----------------------------------
-- !addmission 13 132
-- Dimensional Portal at Crags (Holla/Dem/Mea)
-- Konschtat Highlands : !pos 220 19 300 108
-- La Theine Plateau   : !pos 420 19 20 102
-- Tahrongi Canyon     : !pos 100 35 340 117
-- CSID 7 fires "???: Meet...Altana..." cutscene — matches the
-- mission's premise of a voice from beyond. Verified via puppet bridge
-- 2026-06-18 (short 1-line trigger, deterministic fire).
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.CALL_OF_THE_VOID)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.BOTH_PATHS_TAKEN },
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
            ['Telepoint'] =
            {
                onTrigger = mission:progressEvent(7),
            },
            onEventFinish = { [7] = onFinish },
        },

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            ['Telepoint'] =
            {
                onTrigger = mission:progressEvent(7),
            },
            onEventFinish = { [7] = onFinish },
        },

        [xi.zone.TAHRONGI_CANYON] =
        {
            ['Telepoint'] =
            {
                onTrigger = mission:progressEvent(7),
            },
            onEventFinish = { [7] = onFinish },
        },
    },
}

return mission
