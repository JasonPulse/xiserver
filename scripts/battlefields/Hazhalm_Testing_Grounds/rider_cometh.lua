-----------------------------------
-- Area: Hazhalm Testing Grounds
-- Quest: The Rider Cometh -- Odin Prime
-----------------------------------
-- Retail (bg-wiki "The Rider Cometh"): entered from the Entry Gate after
-- examining it with the Talisman key. Opponent is Odin Prime, who spawns up to
-- three Odin Images and uses Zantetsuken if left alive too long. Trust magic is
-- disabled inside.
--
-- `xi.battlefield.id.RIDER_COMETH` (1184) and the `bcnm_records` row
-- (1184, 78, 'rider_cometh') already existed; the zone therefore already gets a
-- CBattlefieldHandler (see src/map/zone.cpp:414, which keys off a non-empty
-- bcnmname). What was missing was this content script plus the mob wiring:
-- mob_groups 87/88 in zone 78 both had poolid 0, and Odin_Image had no pool at
-- all. Pool 7315 (Odin_Image) is modelled on Alexander_Image (7088), the direct
-- analogue. Spawn points already existed: Odin Prime 17097298, Odin Images
-- 17097299-17097301.
--
-- No edit to npcs/_260.lua is needed: Battlefield:register() auto-appends
-- onTrigger = Battlefield.onEntryTrigger for entryNpc through the Interaction
-- Framework (scripts/globals/battlefield.lua:528). The IF handler claims the
-- trigger when the player qualifies, and falls through to the existing
-- Einherjar lockout path otherwise -- which is exactly what that file's
-- "TODO: Entry point for The Rider Cometh" was asking for.
--
-- exitNpcs is deliberately omitted: the only gate NPC is _260, and registering
-- it as both entry and exit would have the exit onTrigger overwrite the entry
-- onTrigger in the same zone section.
-----------------------------------

local content = BattlefieldQuest:new({
    zoneId        = xi.zone.HAZHALM_TESTING_GROUNDS,
    battlefieldId = xi.battlefield.id.RIDER_COMETH,
    canLoseExp    = true,
    maxPlayers    = 18,
    levelCap      = 75,
    timeLimit     = utils.minutes(15),
    index         = 0,
    entryNpc      = '_260',
    allowTrusts   = false,
    questArea     = xi.questLog.AHT_URHGAN,
    quest         = xi.quest.id.ahtUrhgan.THE_RIDER_COMETH,
    requiredKeyItems = { xi.ki.TALISMAN_KEY },
})

content.groups =
{
    {
        mobs           = { 'Odin_Prime' },
        superlinkGroup = 1,

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },

    -- Odin summons his images mid-fight, so they start unspawned. Killing them
    -- is not a win condition; only Odin Prime's death ends the battlefield.
    {
        mobs           = { 'Odin_Image' },
        superlinkGroup = 1,
        spawned        = false,
    },
}

return content:register()
