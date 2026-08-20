-----------------------------------
-- Area: Ra'Kaznar Turris
-- BCNM: Abomination (Seekers of Adoulin Mission 5-4-1)
-----------------------------------
-- Retail (bg-wiki "Seekers of Adoulin Mission 5-4-1"):
--   "Examine the Ominous Postern in Ra'Kaznar Turris to enter the fight against
--    Hades (Second Form)."
--   "You will be assisted by Arciela and Teodor. The Mission will fail if either
--    die." / "You can only cure Arciela." / "You can do no actions to Teodor."
--   "Hades' HP bar is hidden throughout the entire fight."
--   "After winning, you will be thrown into another cutscene. Following the
--    cutscene, you will be back in Ceizak Battlegrounds."
--   Notes: "Should you lose the battle, re-zone into Ra'Kaznar Inner Court for
--    another {KI} Awakened crystallized psyche."
--
-- TIME LIMIT: a fresh 30 minutes Earth time, independent of Reckoning's.
--
-- ENTRY ITEM: {KI} Awakened crystallized psyche -- the item Reckoning awards --
-- kept rather than consumed, for the same reason as Reckoning's.
--
-- TWO ALLIES, EITHER DEATH LOSES. Arciela is mob_groups 2 (pool 5496) and Teodor
-- is mob_groups 3 (pool 5498 'Theodor'), both allegiance 1 (PLAYER). They are
-- separate groups so either dying independently trips the loss.
--
-- SECOND FORM IS A DIFFERENT MOB. This uses mob_groups 9 (pool 5497 'hadesV2',
-- skill list 487 = twelve abilities), not Reckoning's group 1 / pool 5495 /
-- skill list 485. Group 9 was added and the five Abomination Hades spawn points
-- (17911819/22/25/28/31) repointed onto it -- previously every Hades spawn in the
-- zone shared one group and both forms would have used the first form's kit.
--
-- NOT MODELLED, and deliberately not faked: the elemental-weakness rotation
-- bg-wiki marks with {{verification}} ("Elemental resistances change after using
-- an elemental ability"), and the blue-stagger that strips Incessant Void's
-- Magic Barrier -- that belongs to the stagger system, not this battlefield.
-----------------------------------
local turrisID = zones[xi.zone.RAKAZNAR_TURRIS]
-----------------------------------

local content = BattlefieldMission:new({
    zoneId        = xi.zone.RAKAZNAR_TURRIS,
    battlefieldId = xi.battlefield.id.ABOMINATION,
    isMission     = true,
    canLoseExp    = false,
    allowTrusts   = true,
    maxPlayers    = 6,
    levelCap      = 99,
    timeLimit     = utils.minutes(30),
    index         = 1,
    entryNpc      = 'Ominous_Postern',
    exitNpc       = 'exit',

    requiredKeyItems = { xi.ki.AWAKENED_CRYSTALLIZED_PSYCHE, keep = true },
    missionArea      = xi.mission.log_id.SOA,
    mission          = xi.mission.id.soa.ABOMINATION,
})

content.groups =
{
    -- Hades, second form. mob_groups 9 -> pool 5497 'hadesV2', skill list 487.
    {
        mobIds =
        {
            { turrisID.mob.HADES_SECOND_FORM },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },

    -- bg-wiki: "The Mission will fail if either die." Kept as two groups so each
    -- death is detected on its own.
    {
        mobIds =
        {
            { turrisID.mob.ARCIELA_ABOMINATION },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.LOST)
        end,
    },

    {
        mobIds =
        {
            { turrisID.mob.TEODOR_ABOMINATION },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.LOST)
        end,
    },
}

return content:register()
