-----------------------------------
-- Area: Ra'Kaznar Turris
-- BCNM: Reckoning (Seekers of Adoulin Mission 5-4)
-----------------------------------
-- Retail (bg-wiki "Seekers of Adoulin Mission 5-4"):
--   "Examine the Ominous Postern to enter the fight against Hades (First Form)."
--   "You will be assisted by Arciela. The Mission will fail if she dies."
--   "Upon winning the battle, you will automatically watch another cutscene and
--    receive the {KI} Awakened crystallized psyche."
--   Notes: "Should you lose the battle, re-zone into Ra'Kaznar Inner Court for
--    another {KI} Crystallized psyche." / "Trusts may be used in this battle."
--
-- TIME LIMIT: 30 minutes Earth time, the standard for this fight and the same
-- figure carried by every other 30-minute battlefield in bcnm_records (1800).
--
-- ENTRY ITEM: {KI} Crystallized psyche, kept rather than consumed -- bg-wiki's
-- note about re-zoning for "another" one is the LOSS path, and the mission's own
-- csid 32001 handler in scripts/missions/soa/5_4_0_Reckoning.lua checks the key
-- item is still held on the way out.
--
-- ARCIELA IS AN ALLY, NOT A TARGET. She spawns from mob_groups 2 (pool 5496) with
-- allegiance 1 (PLAYER), matching how she is already set up in Rala Waterways (U).
-- The mission fails if she dies, so her death sets the battlefield to LOSE rather
-- than being ignored.
--
-- Win/loss is reported to the mission through the standard csid 32001
-- battlefield-win event; that handler is gated on the Crystallized psyche so it
-- cannot be driven by any other battlefield added to this zone later.
-----------------------------------
local turrisID = zones[xi.zone.RAKAZNAR_TURRIS]
-----------------------------------

local content = BattlefieldMission:new({
    zoneId        = xi.zone.RAKAZNAR_TURRIS,
    battlefieldId = xi.battlefield.id.RECKONING,
    isMission     = true,
    canLoseExp    = false,
    allowTrusts   = true,
    maxPlayers    = 6,
    levelCap      = 99,
    timeLimit     = utils.minutes(30),
    index         = 0,
    entryNpc      = 'Ominous_Postern',
    exitNpc       = 'exit',

    requiredKeyItems = { xi.ki.CRYSTALLIZED_PSYCHE, keep = true },
    missionArea      = xi.mission.log_id.SOA,
    mission          = xi.mission.id.soa.RECKONING,
})

content.groups =
{
    -- Hades, first form. mob_groups 1 -> pool 5495 'Hadesv1', skill list 485.
    {
        mobIds =
        {
            { turrisID.mob.HADES_FIRST_FORM },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },

    -- Arciela fights alongside the party; bg-wiki: "The Mission will fail if she
    -- dies." She is spawned by the framework but is not a win condition.
    {
        mobIds =
        {
            { turrisID.mob.ARCIELA_RECKONING },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.LOST)
        end,
    },
}

return content:register()
