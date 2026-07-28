-----------------------------------
-- Area: Ilrusi Atoll
--  Mob: Cursed Chest
-- Note: Golden Salvage assault. The coffers are mimics that look like
--       chests until examined; the wrong ones attack, the figurehead wins.
-----------------------------------
local ID = zones[xi.zone.ILRUSI_ATOLL]
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onTrigger = function(player, mob)
    player:messageSpecial(ID.text.CHEST)

    local instance = mob:getInstance()
    if not instance then
        return
    end

    if mob:getID() == instance:getProgress() then
        player:messageSpecial(ID.text.GOLDEN)
        instance:complete()
        for _, v in pairs(ID.mob.CURSED_CHESTS) do
            DespawnMob(v, instance)
        end
    else
        mob:updateClaim(player)
    end
end

local function CheckForDrawnIn(centerX, centerY, centerZ, playerX, playerY, playerZ, rayon, maxRayon)
    local difX = playerX-centerX
    local difY = playerY-centerY
    local difZ = playerZ-centerZ
    local distance = math.sqrt(math.pow(difX, 2) + math.pow(difY, 2) + math.pow(difZ, 2))

    if distance > rayon and distance < maxRayon then
        return true
    else
        return false
    end
end

entity.onMobFight = function(mob, target)
    local playerX = target:getXPos()
    local playerY = target:getYPos()
    local playerZ = target:getZPos()
    local mobX = mob:getXPos()
    local mobY = mob:getYPos()
    local mobZ = mob:getZPos()
    local distanceMin = 3
    local distanceMax = 20

    if CheckForDrawnIn(mobX, mobY, mobZ, playerX, playerY, playerZ, distanceMin, distanceMax) then
        target:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos())
    end
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
