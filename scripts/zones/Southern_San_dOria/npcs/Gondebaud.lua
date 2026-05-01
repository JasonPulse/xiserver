-----------------------------------
-- Area: Southern San d'Oria
--  NPC: Gondebaud
-- Trust NPC
-- !pos 123.754 0.000 92.125 230
-----------------------------------
local ID = zones[xi.zone.SOUTHERN_SAN_DORIA]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    xi.trust.onTradeCipher(player, trade, 3503, 3552, 3553)
end

entity.onTrigger = function(player, npc)
    player:startEvent(3505)
end

entity.onEventFinish = function(player, csid, option, npc)
    if csid == 3503 or csid == 3553 then
        local spellID = player:getLocalVar('TradingTrustCipher')
        player:setLocalVar('TradingTrustCipher', 0)
        player:addSpell(spellID, { silentLog = true })
        player:messageSpecial(ID.text.YOU_LEARNED_TRUST, 0, spellID)
        player:tradeComplete()
    end
end

return entity
