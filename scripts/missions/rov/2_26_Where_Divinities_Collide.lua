-----------------------------------
-- Where Divinities Collide
-- Rhapsodies of Vana'diel Mission 2-26
-----------------------------------
-- !addmission 13 104
-- Shattered Telepoint (Konschtat) : !pos 135 19 220 108
-- Shattered Telepoint (La Theine) : !pos 334 19 -60 102
-- Shattered Telepoint (Tahrongi)  : !pos 179 35 255 117
-- CSID 5 fires the Selh'teus "Phoenix's plume / mothercrystal" cutscene
-- on Shattered Telepoint trigger. Verified via puppet bridge 2026-06-18.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.WHERE_DIVINITIES_COLLIDE)

mission.reward =
{
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.VISIONS_OF_DREAD },
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
                onTrigger = mission:progressEvent(5),
            },
            onEventFinish = { [5] = onFinish },
        },

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(5),
            },
            onEventFinish = { [5] = onFinish },
        },

        [xi.zone.TAHRONGI_CANYON] =
        {
            ['Shattered_Telepoint'] =
            {
                onTrigger = mission:progressEvent(5),
            },
            onEventFinish = { [5] = onFinish },
        },
    },
}

return mission
