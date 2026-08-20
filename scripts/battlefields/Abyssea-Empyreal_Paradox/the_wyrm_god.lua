-----------------------------------
-- Area: Abyssea - Empyreal Paradox
-- BCNM: The Wyrm God (Shinryu)
-----------------------------------
-- Retail (bg-wiki "The Wyrm God", |Previous=Beneath a Blood-red Sky):
--   "Enter Abyssea - Empyreal Paradox through the Transcendental Radiance in
--    Qufim Island at (F-7) for a key item: Crimson traverser stone."
--   "Examine the Transcendental Radiance in the Abyssea - Empyreal Paradox for a
--    short cutscene, examine it again to enter a battlefield."
--   "Your fight is against Shinryu, a Wyrm-type creature."
-- bg-wiki "Shinryu", The Wyrm God section:
--   "Battlefield entry requires 10,000 cruor and a Crimson traverser stone {KI}."
--   "May be fought multiple times after reaching the quest The Wyrm God."
--
-- All of the data for this fight already existed and was simply never wired up:
--   * mob_pools 3604 'Shinryu', skill list 475 (15 unique abilities)
--   * mob_groups (1, 3604, 255, 'Shinryu', ...) -- poolid and dropid 2238 already
--     correct; only HP was 0, now benchmarked (see the note in mob_groups.sql)
--   * mob_spawn_points 17821697/98/99 -- three real spawn positions, one per
--     battlefield instance
--   * TR_Entrance (17821714) and three Transcendental_Radiance exits
--     (17821715/16/17) -- exactly the entry/exit set the framework expects, and
--     the same names apocalypse_nigh.lua uses in the CoP Empyreal Paradox
-- What was missing was Lua only: the battlefield id, the bcnm_records row, and
-- this script.
--
-- PARAMETERS: bg-wiki states neither a time limit nor a party size for this
-- battlefield. They are taken from the closest structural analogue in the repo --
-- scripts/battlefields/Empyreal_Paradox/apocalypse_nigh.lua, the final-boss
-- battlefield of the identically-named CoP zone, which also enters on
-- 'TR_Entrance' and exits on 'Transcendental_Radiance': 30 minutes, MAX_LEVEL
-- cap, trusts allowed. maxPlayers is 18 rather than apocalypse_nigh's 6 because
-- Abyssea content is alliance-scale.
--
-- ENTRY: the Crimson traverser stone is kept, not consumed -- bg-wiki says the
-- fight "may be fought multiple times after reaching the quest", and the Qufim
-- Transcendental Radiance is what charges the 10,000 cruor per stone.
--
-- The quest side is already written and expects exactly this: scripts/quests/
-- abyssea/The_Wyrm_God.lua fires 208 on TR_Entrance for the "short cutscene"
-- (Prog 0 -> 1), then waits on csid 32001 with
-- `battlefieldWin == xi.battlefield.id.THE_WYRM_GOD` to reach Prog 2, then Prishe
-- 203 completes. That comparison was against a nil enum until now, so it was
-- always false and the quest could never progress past the cutscene.
-----------------------------------
local paradoxID = zones[xi.zone.ABYSSEA_EMPYREAL_PARADOX]
-----------------------------------

local content = BattlefieldQuest:new({
    zoneId           = xi.zone.ABYSSEA_EMPYREAL_PARADOX,
    battlefieldId    = xi.battlefield.id.THE_WYRM_GOD,
    allowTrusts      = true,
    maxPlayers       = 18,
    levelCap         = xi.settings.main.MAX_LEVEL,
    timeLimit        = utils.minutes(30),
    index            = 0,
    entryNpc         = 'TR_Entrance',
    exitNpc          = 'Transcendental_Radiance',
    requiredKeyItems = { xi.ki.CRIMSON_TRAVERSER_STONE, keep = true },
    questArea        = xi.questLog.ABYSSEA,
    quest            = xi.quest.id.abyssea.THE_WYRM_GOD,
    requiredVar      = 'Quest[8][184]Prog',
    requiredValue    = 1,
})

content.groups =
{
    {
        mobIds =
        {
            { paradoxID.mob.SHINRYU },
        },

        allDeath = function(battlefield, mob)
            battlefield:setStatus(xi.battlefield.status.WON)
        end,
    },
}

return content:register()
