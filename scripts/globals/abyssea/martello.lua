-----------------------------------
-- Abyssea Martello towers (XX-NN_Martello, 8 per Abyssea field zone).
--
-- Retail behavior (bg-wiki "Martello"): examining a Martello restores 100%
-- HP/MP and removes status ailments, consuming the TOWER's shared energy
-- pool — HP costs 15 energy, MP 30, status removal 10. Each player has a
-- 30-minute reuse timer, reduced 5 minutes per Abyssite of Expertise held
-- (Emerald/Ivory/Jade). Towers hold 3,000 energy and refill slowly on their
-- own. (Retail's Bastion martello-core reduction and the Refuel/Replenish
-- quests are not implemented; the regeneration rate below is our tuning —
-- the wiki does not publish it.)
-----------------------------------
xi = xi or {}
xi.abyssea = xi.abyssea or {}

local energyMax     = 3000
local energyPerMin  = 5     -- passive refill rate (tuned; unpublished on wiki)
local hpCost        = 15
local mpCost        = 30
local statusCost    = 10
local reuseSeconds  = 1800  -- 30 minutes
local abyssiteBonus = 300   -- -5 minutes per Abyssite of Expertise

local expertiseAbyssites =
{
    xi.ki.IVORY_ABYSSITE_OF_EXPERTISE,
    xi.ki.JADE_ABYSSITE_OF_EXPERTISE,
    xi.ki.EMERALD_ABYSSITE_OF_EXPERTISE,
}

-- Lazily-regenerating per-tower energy pool (localvars start at 0, so an
-- untouched tower reads as full).
local towerEnergy = function(npc)
    local now  = GetSystemTime()
    local last = npc:getLocalVar('MartelloEnergyTs')
    if last == 0 then
        npc:setLocalVar('MartelloEnergyTs', now)
        npc:setLocalVar('MartelloEnergy', energyMax)
        return energyMax
    end

    local stored  = npc:getLocalVar('MartelloEnergy')
    local refill  = math.floor((now - last) / 60) * energyPerMin
    local current = math.min(energyMax, stored + refill)
    if refill > 0 then
        npc:setLocalVar('MartelloEnergy', current)
        npc:setLocalVar('MartelloEnergyTs', now)
    end

    return current
end

xi.abyssea.martelloOnTrigger = function(player, npc)
    local now       = GetSystemTime()
    local nextUse   = player:getCharVar('Martello_Reuse')
    local reduction = 0
    for _, ki in ipairs(expertiseAbyssites) do
        if player:hasKeyItem(ki) then
            reduction = reduction + abyssiteBonus
        end
    end

    if now < nextUse then
        player:printToPlayer(string.format('The martello hums softly. It will not respond to you for another %d minute(s).', math.ceil((nextUse - now) / 60)), xi.msg.channel.NS_SAY)
        return
    end

    local needHp     = player:getHP() < player:getMaxHP()
    local needMp     = player:getMaxMP() > 0 and player:getMP() < player:getMaxMP()
    local hasAilment = player:countEffectWithFlag(xi.effectFlag.ERASABLE) > 0
    local cost       = (needHp and hpCost or 0) + (needMp and mpCost or 0) + (hasAilment and statusCost or 0)

    if cost == 0 then
        player:printToPlayer('The martello thrums quietly. You are in no need of its energies.', xi.msg.channel.NS_SAY)
        return
    end

    local energy = towerEnergy(npc)
    if energy < cost then
        player:printToPlayer('The martello sputters — its energy reserves are depleted. Wait for it to replenish.', xi.msg.channel.NS_SAY)
        return
    end

    if needHp then
        player:addHP(player:getMaxHP())
    end

    if needMp then
        player:addMP(player:getMaxMP())
    end

    if hasAilment then
        player:eraseAllStatusEffect()
    end

    npc:setLocalVar('MartelloEnergy', energy - cost)
    player:setCharVar('Martello_Reuse', now + reuseSeconds - reduction)
    player:printToPlayer('A surge of energy from the martello washes over you, restoring body and mind.', xi.msg.channel.NS_SAY)
end
