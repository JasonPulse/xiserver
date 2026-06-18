-----------------------------------
-- Unified pop-item NPC handler.
--
-- Several systems use the "trade a pop KI to spawn a boss" pattern:
--   * Wildskeeper Reives (xi.wildskeeperReives.pops + popBoss)
--   * Geas Fete (xi.geasFete.pops + popBoss)
--
-- Each system's popBoss() checks zone + KI possession before SpawnMob. This
-- module wraps both into a single onTrigger handler that any in-zone NPC
-- (Undulating_Confluence, qm_droplet, Reive zone Waypoints, etc.) can
-- delegate to.
--
-- The player must explicitly opt-in by pinning a pop KI to the
-- `Pop_Selection` CharVar before triggering. We deliberately do NOT
-- auto-scan held KIs — that would risk accidentally popping a boss when the
-- player just wanted the NPC's other functionality (waypoint menu, droplet,
-- etc.) and happened to be carrying the KI for later use.
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

-- Returns true if a pop was attempted (success or failure with a player
-- message). Returns false when the player has nothing pop-able here and
-- the caller should fall through to other NPC behaviour.
xi.popTrigger.tryPop = function(player)
    if not player then
        return false
    end

    local pinned = player:getCharVar(popSelectionVar)
    if pinned == 0 then
        -- No pin = not opted-in. Fall through to the host NPC's normal
        -- behaviour (waypoint menu, droplet grant, etc.). We deliberately do
        -- NOT auto-scan the player's KIs — that risk-of-accidental-pop bit
        -- players who happened to be carrying a pop KI for later use.
        return false
    end

    local popBoss, entry = dispatcherFor(pinned)
    if not (popBoss and entry) then
        player:printToPlayer(string.format('Pop_Selection %d is not a registered pop key item.', pinned))
        return true
    end

    local ok, msg = popBoss(player, pinned)
    if ok then
        player:printToPlayer(msg)
        player:setCharVar(popSelectionVar, 0) -- clear pin on success
    else
        player:printToPlayer(string.format('Pop_Selection %d failed: %s', pinned, msg))
    end

    return true
end
