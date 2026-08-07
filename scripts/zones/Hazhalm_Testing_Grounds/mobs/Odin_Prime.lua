-----------------------------------
-- Area: Hazhalm Testing Grounds
--  Mob: Odin Prime
-- The Rider Cometh battlefield boss.
-----------------------------------
-- Retail (bg-wiki "The Rider Cometh"): Odin Prime casts Paralyze, Dispelga and
-- elemental magic, spawns up to three Odin Images, and uses Zantetsuken if he
-- is left alive for an extended period at low HP.
--
-- Elemental magic already works: pool 6961 uses spellList 5 (Beastmen_DRK ->
-- fire/blizzard/aero/stone lines). Zantetsuken is mob_skills 2126 on skill list
-- 41 ('Avatar-Odin'), which pool 6961 already points at; the list row was
-- commented out upstream and is now enabled, with a script added at
-- scripts/actions/mobskills/zantetsuken.lua.
--
-- The other six 'Avatar-Odin' entries (ofnir, valfodr, yggr, gagnrath,
-- sanngetall, geirrothr) are deliberately left disabled: their mob_skills rows
-- are commented out upstream, they have no scripts, and bg-wiki does not list
-- them for this fight. Enabling them without implementations would give Odin
-- 0-damage weaponskills.
-----------------------------------
local ID = zones[xi.zone.HAZHALM_TESTING_GROUNDS]
-----------------------------------
---@type TMobEntity
local entity = {}

local imageHpThresholds = { 75, 50, 25 }

entity.onMobSpawn = function(mob)
    mob:setLocalVar('imagesSpawned', 0)
end

entity.onMobFight = function(mob, target)
    local spawned = mob:getLocalVar('imagesSpawned')

    if spawned >= #imageHpThresholds then
        return
    end

    -- One image per threshold crossed, to a maximum of three.
    if mob:getHPP() <= imageHpThresholds[spawned + 1] then
        local image    = ID.mob.ODIN_IMAGE[spawned + 1]
        local imageMob = image and GetMobByID(image) or nil

        if imageMob and not imageMob:isSpawned() then
            SpawnMob(image, mob:getInstance())
            imageMob:updateEnmity(target)
        end

        mob:setLocalVar('imagesSpawned', spawned + 1)
    end
end

entity.onMobDeath = function(mob, player, optParams)
    -- Images do not survive their summoner.
    for _, image in ipairs(ID.mob.ODIN_IMAGE) do
        local imageMob = GetMobByID(image)

        if imageMob and imageMob:isSpawned() then
            DespawnMob(image, mob:getInstance())
        end
    end
end

return entity
