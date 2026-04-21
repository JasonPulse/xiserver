-----------------------------------
-- Assault: Golden Salvage
-- TODO: random the chest locations
-----------------------------------
local ID = zones[xi.zone.ILRUSI_ATOLL]
-----------------------------------
local instanceObject = {}

instanceObject.registryRequirements = function(player)
    return player:hasKeyItem(xi.ki.ILRUSI_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.GOLDEN_SALVAGE and
        player:getCharVar('assaultEntered') == 0 and
        player:hasKeyItem(xi.ki.ASSAULT_ARMBAND) and
        player:getMainLvl() > 50
end

instanceObject.entryRequirements = function(player)
    return player:hasKeyItem(xi.ki.ILRUSI_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.GOLDEN_SALVAGE and
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
    GetNPCByID(ID.npc.RUNE_OF_RELEASE, instance):setPos(420, -15, 72, 148)
    GetNPCByID(ID.npc.ANCIENT_LOCKBOX, instance):setPos(415, -15, 75, 148)
    GetNPCByID(ID.npc._1jp, instance):setAnimation(8)
    GetNPCByID(ID.npc._jja, instance):setAnimation(8)
    GetNPCByID(ID.npc._jjb, instance):setAnimation(8)

    -- Progress stores the random figurehead chest NPC ID; Cursed_Chest.lua reads it on trigger
    if instance:getProgress() == 0 then
        local figureheadChest = math.random(ID.npc.ILRUSI_CURSED_CHEST_OFFSET, ID.npc.ILRUSI_CURSED_CHEST_OFFSET + 11)
        instance:setProgress(figureheadChest)
    end
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

instanceObject.onInstanceFailure = function(instance)
    xi.assault.onInstanceFailure(instance)
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
end

instanceObject.onInstanceComplete = function(instance)
    xi.assault.onInstanceComplete(instance, 8, 8)
end

instanceObject.onEventFinish = function(player, csid, option, npc)
end

return instanceObject
