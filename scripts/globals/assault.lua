-----------------------------------
-- Assault Utilities
-- desc: Common functionality for Assaults
-----------------------------------
require('scripts/globals/besieged')
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.assault = xi.assault or {}

xi.assault.assaultOrders =
{
    xi.ki.LEUJAOAM_ASSAULT_ORDERS,
    xi.ki.MAMOOL_JA_ASSAULT_ORDERS,
    xi.ki.LEBROS_ASSAULT_ORDERS,
    xi.ki.PERIQIA_ASSAULT_ORDERS,
    xi.ki.ILRUSI_ASSAULT_ORDERS,
    xi.ki.NYZUL_ISLE_ASSAULT_ORDERS,
}

xi.assault.getAssaultArea = function(player)
    return math.floor((player:getCurrentAssault() - 1) / 10)
end

xi.assault.hasOrders = function(player)
    for _, assaultOrders in pairs(xi.assault.assaultOrders) do
        if player:hasKeyItem(assaultOrders) then
            return true
        end
    end

    return false
end

xi.assault.onAssaultUpdate = function(player, csid, option, npc)
    local ID = zones[player:getZoneID()]

    local cap = bit.band(option, 0x03)
    if cap == 0 then
        cap = 0
    elseif cap == 1 then
        cap = 70
    elseif cap == 2 then
        cap = 60
    else
        cap = 50
    end

    player:setLocalVar('AssaultCap', cap)

    if
        player:getGMLevel() == 0 and
        player:getPartySize() < xi.settings.main.ASSAULT_MINIMUM
    then
        player:messageSpecial(ID.text.MEMBER_TOO_FAR - 1, xi.settings.main.ASSAULT_MINIMUM)
        player:instanceEntry(npc, 1)
        return
    elseif player:checkSoloPartyAlliance() == 2 then
        player:messageText(player, ID.text.MEMBER_NO_REQS + 1, false)
        player:instanceEntry(npc, 1)
        return
    end
end

xi.assault.onInstanceCreatedCallback = function(player, instance)
    if instance then
        instance:setLevelCap(player:getLocalVar('AssaultCap'))
        player:setLocalVar('AssaultCap', 0)
        player:setCharVar('Assault_Armband', 1)
        player:delKeyItem(xi.ki.ASSAULT_ARMBAND)
    else
        local npc = player:getEventTarget()
        player:messageText(player, zones[player:getZoneID()].text.CANNOT_ENTER, false)
        player:instanceEntry(npc, 3)
    end
end

xi.assault.afterInstanceRegister = function(player, fireFlies)
    local instance = player:getInstance()
    local assaultID = player:getCurrentAssault()
    local levelCap = instance:getLevelCap()
    local ID = zones[player:getZoneID()]

    player:setCharVar('assaultEntered', assaultID)
    player:messageSpecial(ID.text.ASSAULT_START_OFFSET + assaultID, assaultID)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit())
    player:addTempItem(fireFlies)

    if levelCap ~= 0 then
        player:addStatusEffect(xi.effect.LEVEL_RESTRICTION, levelCap, 0, 0)
    end

    for _, entity in pairs(ID.mob[assaultID].MOBS_START) do
        SpawnMob(entity, instance)
    end
end

xi.assault.onInstanceFailure = function(instance)
    local chars    = instance:getChars()
    local mobs     = instance:getMobs()
    local exitZone = instance:getEntranceZoneID()

    for _, entity in pairs(mobs) do
        local mobID = entity:getID()
        DespawnMob(mobID, instance)
    end

    -- Warp players straight to the entrance zone on failure. The old code fired
    -- startEvent(102) with no NPC target, so its onEventFinish was never routed to
    -- a warp (the exit handler lives on Rune_of_Release, only reached on success).
    -- Players were left in the failing instance and fell back to the core teardown
    -- path, which resets position to 0,0,0 -> black screen. setPos(0,0,0,0, zone)
    -- is the same warp the success path uses; the entrance zone's onZoneIn repositions.
    for _, entity in pairs(chars) do
        entity:messageSpecial(zones[instance:getZone():getID()].text.MISSION_FAILED, 10, 10)
        entity:setPos(0, 0, 0, 0, exitZone)
    end
end

xi.assault.onInstanceComplete = function(instance, posX, posZ)
    local chars = instance:getChars()
    local ID = zones[instance:getZone():getID()]

    GetNPCByID(ID.npc.RUNE_OF_RELEASE, instance):setStatus(xi.status.NORMAL)
    GetNPCByID(ID.npc.ANCIENT_LOCKBOX, instance):setStatus(xi.status.NORMAL)

    for _, entity in pairs(chars) do
        entity:messageSpecial(ID.text.RUNE_UNLOCKED_POS, posX, posZ)
    end
end

xi.assault.instanceOnEventFinish = function(player, csid, zone)
    if csid == 102 then
        local instance = player:getInstance()
        local chars = instance:getChars()
        for _, entity in pairs(chars) do
            entity:setPos(0, 0, 0, 0, zone)
        end
    end
end

xi.assault.runeReleaseFinish = function(player, csid, option, npc)
    if csid == 100 and option == 1 then
        local instance = player:getInstance()
        local chars = instance:getChars()
        local zone = player:getZoneID()
        local ID = zones[zone]
        local playerpoints = math.max((#chars - 3) * 0.1, 0)
        local points = 0
        local assaultID = player:getCurrentAssault()
        local mobs = instance:getMobs()
        local pointsArea = xi.assault.getAssaultArea(player)

        for _, entity in pairs(mobs) do
            local mobID = entity:getID()
            DespawnMob(mobID, instance)
        end

        for _, entity in pairs(chars) do
            if entity:getLocalVar('AssaultPointsAwarded') == 0 then
                entity:setLocalVar('AssaultPointsAwarded', 1)

                local pointModifier = xi.assault.missionInfo[assaultID].minimumPoints
                points = pointModifier - (pointModifier * playerpoints)
                if entity:getCharVar('Assault_Armband') == 1 then
                    points = points * 1.1
                end

                if entity:hasCompletedAssault(assaultID) then
                    points = math.floor(points)
                    entity:setVar('AssaultPromotion', entity:getCharVar('AssaultPromotion') + 1)
                    entity:addAssaultPoint(pointsArea, points)
                    entity:messageSpecial(ID.text.ASSAULT_POINTS_OBTAINED, points)
                else
                    points = math.floor(points * 1.5)
                    entity:setVar('AssaultPromotion', entity:getCharVar('AssaultPromotion') + 5)
                    entity:addAssaultPoint(pointsArea, points)
                    entity:messageSpecial(ID.text.ASSAULT_POINTS_OBTAINED, points)
                end

                entity:setVar('AssaultComplete', 1)
                entity:startEvent(102)
            end
        end
    end
end

xi.assault.adjustMobLevel = function(mob)
    local instance = mob:getInstance()
    local levelCap = instance:getLevelCap()
    local reducedLevel = 0
    local entity = GetMobByID(mob:getID(), instance)

    if levelCap ~= 0 then
        if levelCap == 70 then
            reducedLevel = 5
        elseif levelCap == 60 then
            reducedLevel = 15
        elseif levelCap == 50 then
            reducedLevel = 25
        end

        if entity then
            entity:setMobLevel(entity:getMainLvl() - reducedLevel)
        end
    end
end

-----------------------------------
-- Simplified assault dispatch (4-player private server).
--
-- Retail Assault requires Sorrowful Sage / Bhoy Yhupplo / etc. to dispatch
-- you with orders, then Runic Portal to warp in. The dispatch event flow
-- needs in-game CSID verification. This module bypasses the dispatch event
-- entirely: pin which assault zone, the next onGameIn grants the matching
-- Assault Orders KI. Once you have the KI, the existing Runic_Portal NPC
-- in Aht Urhgan Whitegate (already wired) handles the warp.
--
-- Usage:
--   !setvar Assault_Selection N    (1=Leujaoam, 2=Mamool Ja Training Grounds,
--                                   3=Lebros, 4=Periqia, 5=Ilrusi, 6=Nyzul Isle)
--   then zone / relog → trigger Runic Portal in Aht Urhgan Whitegate
-----------------------------------
local assaultPinVar = 'Assault_Selection'
local assaultOrdersList =
{
    [1] = { name = 'Leujaoam Sanctum',           ki = xi.ki.LEUJAOAM_ASSAULT_ORDERS   },
    [2] = { name = 'Mamool Ja Training Grounds', ki = xi.ki.MAMOOL_JA_ASSAULT_ORDERS  },
    [3] = { name = 'Lebros Cavern',              ki = xi.ki.LEBROS_ASSAULT_ORDERS     },
    [4] = { name = 'Periqia',                    ki = xi.ki.PERIQIA_ASSAULT_ORDERS    },
    [5] = { name = 'Ilrusi Atoll',               ki = xi.ki.ILRUSI_ASSAULT_ORDERS     },
    [6] = { name = 'Nyzul Isle',                 ki = xi.ki.NYZUL_ISLE_ASSAULT_ORDERS },
}

xi.assault.tryGrantOrders = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(assaultPinVar)
    if pinned == 0 then
        return false
    end

    local entry = assaultOrdersList[pinned]

    -- Defer client-visible side effects (KI grant message + printToPlayer)
    -- past zone-in; messages fired during onGameIn race the chat/UI buffer
    -- init and never render. Pin cleared synchronously to prevent double-
    -- grant on rapid zone-ins.
    player:setCharVar(assaultPinVar, 0)

    player:timer(3000, function(p)
        if not entry then
            p:printToPlayer(string.format('Assault_Selection %d is not valid (1-6). See assault.lua.', pinned))
            return
        end

        -- Clear any existing assault orders before granting (only one at a time).
        for _, other in pairs(assaultOrdersList) do
            if other.ki ~= entry.ki and p:hasKeyItem(other.ki) then
                p:delKeyItem(other.ki)
            end
        end

        if p:hasKeyItem(entry.ki) then
            p:printToPlayer(string.format('You already hold %s Assault Orders. Trigger the Runic Portal to warp in.', entry.name))
            return
        end

        npcUtil.giveKeyItem(p, entry.ki)
        p:printToPlayer(string.format('%s Assault Orders granted. Trigger the Runic Portal in Aht Urhgan Whitegate to warp in.', entry.name))
    end)

    return true
end
