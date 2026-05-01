-----------------------------------
-- Area: Windurst Woods
--  NPC: Wetata
-- Trust NPC
-- !pos -23.825 2.533 -44.567 241
-----------------------------------
local ID = zones[xi.zone.WINDURST_WOODS]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.trust.onTradeCipher(player, trade, 862, 901, 902)
end

entity.onTrigger = function(player, npc)
    player:startEvent(868)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 862 or csid == 902 then
        local spellID = player:getLocalVar('TradingTrustCipher')
        player:setLocalVar('TradingTrustCipher', 0)
        player:addSpell(spellID, { silentLog = true })
        player:messageSpecial(ID.text.YOU_LEARNED_TRUST, 0, spellID)
        player:tradeComplete()
    end
end

return entity
