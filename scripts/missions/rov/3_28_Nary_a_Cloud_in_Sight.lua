-----------------------------------
-- Nary a Cloud in Sight
-- Rhapsodies of Vana'diel Mission 3-28
-----------------------------------
-- !addmission 13 210
-- La Theine Plateau - Iroha/Selh'teus stone circle cutscene (event 17)
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.NARY_A_CLOUD_IN_SIGHT)

mission.reward =
{
    keyItem     = xi.ki.RHAPSODY_IN_OCHRE,
    item        = xi.item.CIPHER_OF_IROHAS_ALTER_EGO,
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.AN_UNENDING_SONG },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.LA_THEINE_PLATEAU] =
        {
            onZoneIn = function(player, prevZone)
                return 17
            end,

            onEventFinish =
            {
                [17] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
