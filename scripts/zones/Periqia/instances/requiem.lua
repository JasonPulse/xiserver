-----------------------------------
-- Assault: Requiem
-- TODO: random the chest locations
-----------------------------------
local ID = zones[xi.zone.PERIQIA]
-----------------------------------
local instanceObject = {}

instanceObject.registryRequirements = function(player)
    return player:hasKeyItem(xi.ki.PERIQIA_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.REQUIEM and
        player:getCharVar('assaultEntered') == 0 and
        player:hasKeyItem(xi.ki.ASSAULT_ARMBAND) and
        player:getMainLvl() > 50
end

instanceObject.entryRequirements = function(player)
    return player:hasKeyItem(xi.ki.PERIQIA_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.REQUIEM and
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

    xi.assault.afterInstanceRegister(player, xi.item.CAGE_OF_REEF_FIREFLIES)
    GetNPCByID(ID.npc.RUNE_OF_RELEASE, instance):setPos(-489.346, -9.78, -326.579, 90)
    GetNPCByID(ID.npc.ANCIENT_LOCKBOX, instance):setPos(-491.96, -9.668, -322.733, 90)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

instanceObject.onInstanceFailure = function(instance)
    xi.assault.onInstanceFailure(instance)
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
    if progress >= 18 then
        instance:complete()
    end
end

instanceObject.onInstanceComplete = function(instance)
    xi.assault.onInstanceComplete(instance, 5, 9)
end

instanceObject.onEventFinish = function(player, csid, option, npc)
end

return instanceObject
