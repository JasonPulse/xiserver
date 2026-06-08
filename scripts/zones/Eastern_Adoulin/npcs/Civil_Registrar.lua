-----------------------------------
-- Area: Eastern Adoulin
--  NPC: Civil Registrar
-- Type: Coalition membership grantor (simplified stub).
--
-- Retail: each Civil Registrar enrolls the player in their specific coalition
-- and the player picks one to join at a time via a CSID menu.
--
-- Our stub: any Civil Registrar grants rank 1 in all 6 coalitions on first
-- click. Once a player has any non-zero coalition rank we treat them as
-- registered and the NPC does nothing further. This unlocks the gated Bayld
-- vendors (Vesca, Craggy_Bluff, Wortherton, Kithvalio, Ceciliotte) and SOA
-- mission progression without requiring per-coalition menu plumbing.
-----------------------------------
require('scripts/globals/coalition')
-----------------------------------
---@type TNpcEntity
local entity = {}

local function alreadyRegistered(player)
    for coalitionId, _ in pairs(xi.coalition.varNames) do
        if xi.coalition.getRank(player, coalitionId) > 0 then
            return true
        end
    end
    return false
end

entity.onTrigger = function(player, npc)
    if alreadyRegistered(player) then
        player:printToPlayer('You are already registered with the Adoulin coalitions.')
        return
    end

    for coalitionId, _ in pairs(xi.coalition.varNames) do
        xi.coalition.setRank(player, coalitionId, 1)
    end

    player:printToPlayer('Welcome to Adoulin, pioneer. You are now a member of all six coalitions at rank 1.')
end

return entity
