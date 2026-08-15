-----------------------------------
-- Assault: Lamia No.13
-- instance 5501
-----------------------------------
-- Retail (bg-wiki "Lamia No.13"):
--   Assault Area : Ilrusi Atoll
--   Badge Rank   : Private First Class
--   Orders       : Eliminate Lamia No.13
--   Time         : 30 minutes
--   Level        : Lvl. 70
--   Points       : 1200
--   Description  : "Your mission is to hunt down Lamia No.13, a fearsome creature
--                  known to have performed vile experiments on the countless
--                  corpses of her enemies."
--
-- Both of those numbers were already correct in our data before this script
-- existed: scripts/enum/assault.lua has LAMIA_NO_13 = 42 with
-- `{ suggestedLevel = 70, minimumPoints = 1200 }`, matching bg-wiki exactly.
--
-- WHY THIS FILE WAS MISSING, AND WHY IT IS WRITABLE NOW.
-- `sql/instance_list.sql` already carried an ACTIVE row for this assault --
-- (5501,'lamia_no_13',55,54,30, 155.000,-7.000,-175.000, 47) -- with real,
-- researched start coordinates, unlike the 34 unimplemented Assault rows in that
-- file which are commented out and carry 0.000/0.000/0.000 placeholders. So the
-- entry data was ready and only the script was absent, which left a dead end: a
-- player could register Lamia No.13 at the staging point (the enum defines it, so
-- `getCurrentAssault()` can return 42) and then fail to enter, because
-- luautils.cpp:2047 resolves the instance to
-- scripts/zones/<Zone>/instances/<name>.lua and there was no such file.
--
-- The mob data is complete too, which is what makes this buildable rather than
-- blocked:
--   mob_pools        2340 'Lamia_No13', family 171
--   mob_groups       (3, 2340, 55, 'Lamia_No13', respawn 0) -- zone 55, pop-only
--   mob_spawn_points 17002517 at (24.381, -4.094, -209.261) rot 42, level 77-78
--
-- Contrast with the other dangling row, `orichalcum_survey` (6901): its objective
-- needs Mineral Worms, and `Mineral_Worm` appears in NONE of mob_pools,
-- mob_groups or mob_spawn_points, so that one genuinely cannot be built and has
-- been commented out in instance_list.sql instead.
--
-- Structure follows this zone's own extermination.lua / golden_salvage.lua, so
-- the shared helpers do the work: xi.assault.afterInstanceRegister spawns
-- everything in ID.mob[assaultID].MOBS_START, applies the level restriction from
-- missionInfo and hands out the temp item, and xi.assault.onInstanceComplete
-- reveals the Rune of Release and Ancient Lockbox.
--
-- NEEDS AN IN-GAME CHECK: the Rune of Release / Ancient Lockbox coordinates. The
-- other assaults in this zone place them explicitly and retail positions for this
-- one are not documented on bg-wiki, so they are set just clear of Lamia No.13's
-- own spawn point. The pair are the reward chest, so a wrong spot is cosmetic --
-- it cannot block completion -- but it is a guess and is marked as one. The
-- position passed to onInstanceComplete is what gets messaged to the party, so it
-- should match wherever they end up.
-----------------------------------
local ID = zones[xi.zone.ILRUSI_ATOLL]
-----------------------------------
local instanceObject = {}

instanceObject.registryRequirements = function(player)
    return player:hasKeyItem(xi.ki.ILRUSI_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.LAMIA_NO_13 and
        player:getCharVar('assaultEntered') == 0 and
        player:hasKeyItem(xi.ki.ASSAULT_ARMBAND) and
        player:getMainLvl() > 50
end

instanceObject.entryRequirements = function(player)
    return player:hasKeyItem(xi.ki.ILRUSI_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.LAMIA_NO_13 and
        player:getCharVar('assaultEntered') == 0 and
        player:getMainLvl() > 50
end

instanceObject.onInstanceCreated = function(instance)
end

instanceObject.onInstanceCreatedCallback = function(player, instance)
    xi.assault.onInstanceCreatedCallback(player, instance)
    xi.instance.onInstanceCreatedCallback(player, instance)
end

instanceObject.afterInstanceRegister = function(player)
    local instance = player:getInstance()

    -- Spawns MOBS_START (Lamia No.13), applies the level 70 restriction from
    -- missionInfo, and grants the Ilrusi temp item as the other two assaults in
    -- this zone do.
    xi.assault.afterInstanceRegister(player, xi.item.CAGE_OF_REEF_FIREFLIES)

    GetNPCByID(ID.npc.RUNE_OF_RELEASE, instance):setPos(27.000, -4.094, -206.000, 42)
    GetNPCByID(ID.npc.ANCIENT_LOCKBOX, instance):setPos(25.000, -4.094, -205.000, 42)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

instanceObject.onInstanceFailure = function(instance)
    xi.assault.onInstanceFailure(instance)
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
    -- One objective, one kill. Lamia_No13.lua bumps progress on her death.
    if progress >= 1 then
        instance:complete()
    end
end

instanceObject.onInstanceComplete = function(instance)
    xi.assault.onInstanceComplete(instance, 27, -206)
end

instanceObject.onEventFinish = function(player, csid, option, npc)
end

return instanceObject
