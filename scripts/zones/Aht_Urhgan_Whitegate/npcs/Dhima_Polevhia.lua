-----------------------------------
-- Area: Aht Urhgan Whitegate (50)
--  NPC: Dhima Polevhia
-- Type: PUP AF Commission NPC (custom, modeled on Octavien/Wescolina)
-- !pos 67.802 -6.000 26.315 50
-- Trades a single crystal to commission PUP AF body/hands/legs/feet after
-- Puppetmaster Blues completion.
-----------------------------------
---@type TNpcEntity
local entity = {}

local pupCommissions =
{
    { item = xi.item.PUPPETRY_TOBE,      cost = 10000, name = 'Puppetry Tobe (Body)',    tradeItem = xi.item.FIRE_CRYSTAL  },
    { item = xi.item.PUPPETRY_DASTANAS,  cost =  8000, name = 'Puppetry Dastanas (Hands)', tradeItem = xi.item.ICE_CRYSTAL   },
    { item = xi.item.PUPPETRY_CHURIDARS, cost = 10000, name = 'Puppetry Churidars (Legs)', tradeItem = xi.item.WIND_CRYSTAL  },
    { item = xi.item.PUPPETRY_BABOUCHES, cost =  8000, name = 'Puppetry Babouches (Feet)', tradeItem = xi.item.EARTH_CRYSTAL },
}

local function hasUnlockedCommissions(player)
    return player:getQuestStatus(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.PUPPETMASTER_BLUES) == xi.questStatus.QUEST_COMPLETED
end

entity.onTrade = function(player, npc, trade)
    if not hasUnlockedCommissions(player) then
        return
    end

    for _, commission in ipairs(pupCommissions) do
        if npcUtil.tradeHasExactly(trade, { commission.tradeItem }) then
            local standing = player:getCurrency('imperial_standing')
            if standing >= commission.cost then
                if npcUtil.giveItem(player, commission.item) then
                    player:confirmTrade()
                    player:setCurrency('imperial_standing', standing - commission.cost)
                    player:printToPlayer('Dhima Polevhia: Here is your ' .. commission.name .. '!', xi.msg.channel.NS_SAY)
                end
            else
                player:printToPlayer('Dhima Polevhia: You need ' .. commission.cost .. ' Imperial Standing. You only have ' .. standing .. '.', xi.msg.channel.NS_SAY)
            end

            return
        end
    end
end

entity.onTrigger = function(player, npc)
    if hasUnlockedCommissions(player) then
        local standing = player:getCurrency('imperial_standing')
        player:printToPlayer('Dhima Polevhia: I can commission puppetry armor. Trade a crystal to select:', xi.msg.channel.NS_SAY)
        player:printToPlayer('  Fire Crystal  -> Puppetry Tobe (Body) - 10,000 IS',        xi.msg.channel.NS_SAY)
        player:printToPlayer('  Ice Crystal   -> Puppetry Dastanas (Hands) - 8,000 IS',    xi.msg.channel.NS_SAY)
        player:printToPlayer('  Wind Crystal  -> Puppetry Churidars (Legs) - 10,000 IS',   xi.msg.channel.NS_SAY)
        player:printToPlayer('  Earth Crystal -> Puppetry Babouches (Feet) - 8,000 IS',    xi.msg.channel.NS_SAY)
        player:printToPlayer('Your Imperial Standing: ' .. standing, xi.msg.channel.NS_SAY)
    else
        player:printToPlayer('Dhima Polevhia: Complete Puppetmaster Blues before I can commission armor for you.', xi.msg.channel.NS_SAY)
    end
end

return entity
