-----------------------------------
-- The Orb's Radiance
-- Rhapsodies of Vana'diel Mission 3-34
-----------------------------------
-- !addmission 13 224
-- Reisenjima Sanctorium (zone 293, NOT Empyreal Paradox).
-- Defeat Cloud of Darkness. Real onMobDeath wired against entity
-- 17977400 (group 1, pool 4819, family 497, lv130 / 20000 HP).
-- Earlier stub fired in EMPYREAL_PARADOX (zone 36) — wrong zone, same
-- bug shape as Sempurne (3-17). Reward grants the Scintillating Rhapsody
-- KI + Cipher: Iroha II + chains the final mission (A Rhapsody for the Ages).
-- Multi-phase / ally NPC mechanics are AI-side, not handled here.
-----------------------------------

local mission = Mission:new(xi.mission.log_id.ROV, xi.mission.id.rov.THE_ORBS_RADIANCE)

mission.reward =
{
    keyItem     = xi.ki.SCINTILLATING_RHAPSODY,
    item        = xi.item.CIPHER_OF_IROHAS_ALTER_EGO_II,
    nextMission = { xi.mission.log_id.ROV, xi.mission.id.rov.A_RHAPSODY_FOR_THE_AGES },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.REISENJIMA_SANCTORIUM] =
        {
            ['Cloud_of_Darkness'] =
            {
                onMobDeath = function(mob, player, optParams)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
