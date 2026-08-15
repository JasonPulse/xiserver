-----------------------------------
-- Escort for Hire shared state
--
-- The nations' Escort for Hire quests (Bastok 70, San d'Oria 103) share three
-- rules that bg-wiki states on the common "Escort for Hire" page rather than on
-- any one nation's page:
--   * only one Escort for Hire contract may be active at a time
--   * only one may be COMPLETED per Conquest Tally
--   * the 10,000 gil bonus is paid on the first completion of ANY of them
-- All of them therefore have to share state, which is what this file holds.
--
-- The escort NPC's timer (Olavia in Crawlers' Nest, Cannau in Eldieme
-- Necropolis) lives here too so the quest files stay declarative.
--
-- CharVars used:
--   EscortForHireContract  quest id of the live contract, 0 when none
--   EscortForHireCleared   1 once the 10,000 gil bonus has been paid
--   EscortForHireTally     1 until the next Conquest Tally, then auto-expires
--
-- LocalVars used -- deliberately not persistent, so a contract does not survive
-- a zone out, which is what retail's "you have lost sight of her" failure means:
--   escortDeadline   GetSystemTime() value the limit expires at
--   escortFollowing  1 while the escort is walking, 0 while stopped
-----------------------------------

xi.escort = xi.escort or {}

xi.escort.hasActiveContract = function(player)
    return player:getCharVar('EscortForHireContract') ~= 0
end

xi.escort.setActiveContract = function(player, questId)
    player:setCharVar('EscortForHireContract', questId)
end

xi.escort.clearContract = function(player)
    player:setCharVar('EscortForHireContract', 0)
    player:setLocalVar('escortDeadline', 0)
    player:setLocalVar('escortFollowing', 0)
end

-- bg-wiki: "Only one Escort for Hire quest can be completed once per Conquest
-- Tally." setCharVar's third argument is an expiry timestamp, so the flag clears
-- itself at the next tally -- the same pattern conquest.lua uses for the exp ring
-- recharge (scripts/globals/conquest.lua:1163).
xi.escort.tallyAllows = function(player)
    return player:getCharVar('EscortForHireTally') == 0
end

xi.escort.stampTally = function(player)
    player:setCharVar('EscortForHireTally', 1, NextConquestTally())
end

-- Cancelling at the contract giver: retail lets you back out, which drops the
-- quest back to available and frees the contract slot.
xi.escort.cancelContract = function(player, logId, questId)
    player:delQuest(logId, questId)
    xi.escort.clearContract(player)
end

-- The escort NPCs ship as npc_list.status = 2 (DISAPPEAR), so they do not render
-- and cannot be clicked until something reveals them. Nothing did, which made both
-- Escort for Hire quests unfinishable: the contract started, the player zoned in,
-- and there was no NPC to talk to. Olavia is sql/npc_list.sql:23085 and Cannau
-- :22905, both with status 2.
--
-- setStatus is global for a non-instanced zone, so the escort becomes visible to
-- everyone once any player starts a contract. That matches how the rest of the
-- repo reveals on-demand NPCs (treasure.lua:1681, conquest.lua:643) and is
-- acceptable here; the one-active-contract rule keeps it to a single escort at a
-- time anyway.
xi.escort.spawnEscort = function(escortId)
    local npc = GetNPCByID(escortId)

    if npc then
        npc:setStatus(xi.status.NORMAL)
    end
end

xi.escort.despawnEscort = function(escortId)
    local npc = GetNPCByID(escortId)

    if npc then
        npc:setStatus(xi.status.DISAPPEAR)
    end
end

xi.escort.startEscort = function(player, minutes, escortId)
    player:setLocalVar('escortDeadline', GetSystemTime() + (minutes * 60))
    player:setLocalVar('escortFollowing', 1)

    if escortId then
        xi.escort.spawnEscort(escortId)
    end
end

xi.escort.isEscortLive = function(player)
    local deadline = player:getLocalVar('escortDeadline')

    return deadline ~= 0 and GetSystemTime() < deadline
end

xi.escort.endEscort = function(player, escortId)
    player:setLocalVar('escortDeadline', 0)
    player:setLocalVar('escortFollowing', 0)

    if escortId then
        xi.escort.despawnEscort(escortId)
    end
end

-- Talking to the escort toggles between walking and waiting.
xi.escort.toggleFollow = function(player)
    local following = player:getLocalVar('escortFollowing')

    player:setLocalVar('escortFollowing', following == 1 and 0 or 1)
end

-- The escort hands over the Completion certificate only at the end of her route.
-- Without waypoint data for the three retail paths this cannot be a position
-- test, so it is the second conversation onward -- documented as simplified in
-- both quest files rather than passed off as retail.
xi.escort.atStopPoint = function(player)
    return player:getLocalVar('escortFollowing') == 0
end
