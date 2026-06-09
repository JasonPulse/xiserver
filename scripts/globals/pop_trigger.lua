-----------------------------------
-- Unified pop-item NPC handler.
--
-- Several systems use the "trade a pop KI to spawn a boss" pattern:
--   * Wildskeeper Reives (xi.wildskeeperReives.pops + popBoss)
--   * Geas Fete (xi.geasFete.pops + popBoss)
--
-- Each system's popBoss() checks zone + KI possession before SpawnMob. This
-- module wraps both into a single onTrigger handler that any in-zone NPC
-- (Undulating_Confluence, qm_droplet, an Eschan portal helper, etc.) can
-- delegate to. The player optionally pins a specific KI via the
-- `Pop_Selection` CharVar; if unset we scan all registered pops and fire
-- whichever KI the player holds that maps to the current zone.
--
-- Usage (in any NPC script):
--   require('scripts/globals/pop_trigger')
--   entity.onTrigger = function(player, npc)
--       if xi.popTrigger.tryPop(player) then return end
--       -- fall through to the NPC's other behaviour (teleport menu, etc.)
--   end
-----------------------------------
require('scripts/globals/wildskeeper_reives')
require('scripts/globals/geas_fete')
-----------------------------------
xi = xi or {}
xi.popTrigger = xi.popTrigger or {}

local popSelectionVar = 'Pop_Selection'

-- Returns the popBoss dispatcher for a given KI by scanning each system's
-- registered pop table. nil if the KI isn't a known pop.
local function dispatcherFor(kiId)
    if
        xi.wildskeeperReives and
        xi.wildskeeperReives.pops and
        xi.wildskeeperReives.pops[kiId]
    then
        return xi.wildskeeperReives.popBoss, xi.wildskeeperReives.pops[kiId]
    end

    if
        xi.geasFete and
        xi.geasFete.pops and
        xi.geasFete.pops[kiId]
    then
        return xi.geasFete.popBoss, xi.geasFete.pops[kiId]
    end

    return nil, nil
end

-- Scan every registered pop table for a KI the player holds that maps to
-- the player's current zone. Returns (kiId, entry) or nil.
local function findHeldPopForZone(player)
    local zoneId = player:getZoneID()

    local function scan(popTable)
        if not popTable then
            return nil, nil
        end

        for kiId, entry in pairs(popTable) do
            if entry.zoneId == zoneId and player:hasKeyItem(kiId) then
                return kiId, entry
            end
        end

        return nil, nil
    end

    local kiId, entry = scan(xi.wildskeeperReives and xi.wildskeeperReives.pops)
    if kiId then
        return kiId, entry, xi.wildskeeperReives.popBoss
    end

    kiId, entry = scan(xi.geasFete and xi.geasFete.pops)
    if kiId then
        return kiId, entry, xi.geasFete.popBoss
    end

    return nil, nil, nil
end

-- Returns true if a pop was attempted (success or failure with a player
-- message). Returns false when the player has nothing pop-able here and
-- the caller should fall through to other NPC behaviour.
xi.popTrigger.tryPop = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(popSelectionVar)
    if pinned ~= 0 then
        local popBoss, entry = dispatcherFor(pinned)
        if popBoss and entry then
            local ok, msg = popBoss(player, pinned)
            if ok then
                player:printToPlayer(msg)
                player:setCharVar(popSelectionVar, 0) -- clear pin on success
            else
                player:printToPlayer(string.format('Pop_Selection %d failed: %s', pinned, msg))
            end

            return true
        end

        player:printToPlayer(string.format('Pop_Selection %d is not a registered pop key item.', pinned))
        return true
    end

    -- No pin: auto-scan for the first KI the player holds that maps here.
    local kiId, entry, popBoss = findHeldPopForZone(player)
    if not kiId then
        return false
    end

    local ok, msg = popBoss(player, kiId)
    player:printToPlayer(ok and msg or string.format('Pop attempt for %s failed: %s', entry.label, msg))
    return true
end
