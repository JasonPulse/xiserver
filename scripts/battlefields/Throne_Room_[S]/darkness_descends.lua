-----------------------------------
-- Area: Throne Room (S)
-- Mission BC: Darkness Descends (WotG mission 37)
-- Fight Aquila and Haudrale with Lilisette as an ally; the battle is lost
-- if Lilisette falls (bg-wiki "Darkness Descends").
-- NOTE: entryNpc _4c0 is the first of the zone's five circle objects
-- (_4c0.._4c4); verify the circle opens this BC on the first live pass.
-----------------------------------
local throneRoomSID = zones[xi.zone.THRONE_ROOM_S]
-----------------------------------

local content = BattlefieldMission:new({
    zoneId        = xi.zone.THRONE_ROOM_S,
    battlefieldId = xi.battlefield.id.DARKNESS_DESCENDS,
    canLoseExp    = false,
    isMission     = true,
    allowTrusts   = true,
    maxPlayers    = 6,
    timeLimit     = utils.minutes(30),
    index         = 0,
    entryNpc      = '_4c0',
    exitNpc       = '_4c1',

    missionArea   = xi.mission.log_id.WOTG,
    mission       = xi.mission.id.wotg.DARKNESS_DESCENDS,
    requiredVar   = 'Mission[5][36]Status',
    requiredValue = 1,
})

content.groups =
{
    -- Aquila + Haudrale: defeating both wins the battlefield.
    {
        mobIds =
        {
            { throneRoomSID.mob.AQUILA,     throneRoomSID.mob.HAUDRALE     },
            { throneRoomSID.mob.AQUILA + 3, throneRoomSID.mob.HAUDRALE + 3 },
            { throneRoomSID.mob.AQUILA + 6, throneRoomSID.mob.HAUDRALE + 6 },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },

    -- Lilisette fights alongside the party; her death loses the battle.
    {
        mobIds =
        {
            { throneRoomSID.mob.LILISETTE     },
            { throneRoomSID.mob.LILISETTE + 3 },
            { throneRoomSID.mob.LILISETTE + 6 },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.LOST)
        end,
    },
}

return content:register()
