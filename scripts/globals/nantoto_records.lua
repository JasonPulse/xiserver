-----------------------------------
-- Nantoto's Records of Eminence chain, shared helpers.
--
-- Nantoto in Lower Jeuno runs a chain of quests whose objectives are Records of
-- Eminence tasks, each gated on a running total of completed RoE objectives:
--
--   Teleports by Twilight    50 objectives, touch all six telepoint crystals
--   Shifty Shades of Prey   100 objectives, defeat ten Fomor in Eldieme Necropolis
--   Petals of Recollection  103 objectives, light a firework somewhere meaningful
--   To Kill Mocking Birds   150 objectives, defeat a Yagudo High Priest in Oztroja
--   Remembrance of Flowers  999 objectives, light a firework in the same place
--
-- THE GATE IS REAL AND ALREADY BOUND. `player:getNumEminenceCompleted()` exists; it
-- is what roe.lua itself uses for hidden record 4085, "10 RoE Objectives Complete".
-- So "complete N separate Records of Eminence objectives" needs nothing new.
--
-- THE OBJECTIVES ARE NOT RoE RECORDS HERE. Retail asks the player to activate a
-- matching record (Telepoint Pilgrimage, Culling the Darkness, Grudge) and tracks the
-- task through the RoE engine. None of those records exist in roe_records.lua, and
-- the engine has no trigger type that fits some of them anyway. The tasks are
-- therefore tracked by the quests themselves, through interaction-framework hooks
-- that DO exist: onTrigger for the telepoint crystals and onMobDeath for the kills.
-- The observable outcome is identical; what a player loses is the RoE log entry.
--
-- Sparks are paid the way roe.lua pays them, through the spark_of_eminence currency
-- with the server's SPARKS_RATE applied, so these stay consistent with every other
-- RoE payout rather than inventing a second path.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------

xi = xi or {}
xi.nantoto = xi.nantoto or {}

--- The six telepoint crystals. The three Campaign-era [S] telepoints are deliberately
--- excluded: bg-wiki says "all six telepoint crystals", and these are the six.
--- This is an ORDERED list, not a zone-keyed map, because each entry's position is
--- used as a bit index in the player's progress mask. Lua's pairs() has no defined
--- order, so a map would hand out different bits on different runs.
xi.nantoto.telepoints =
{
    { zone = xi.zone.LA_THEINE_PLATEAU,     npc = 17195618 },
    { zone = xi.zone.KONSCHTAT_HIGHLANDS,   npc = 17220138 },
    { zone = xi.zone.XARCABARD,             npc = 17236309 },
    { zone = xi.zone.EASTERN_ALTEPA_DESERT, npc = 17244619 },
    { zone = xi.zone.TAHRONGI_CANYON,       npc = 17257041 },
    { zone = xi.zone.YHOATOR_JUNGLE,        npc = 17285647 },
}

--- Pay a Nantoto reward the same way the RoE engine does.
---@param player CBaseEntity
---@param sparks integer
---@param exp integer
---@param vouchers integer
xi.nantoto.payReward = function(player, sparks, exp, vouchers)
    if sparks > 0 then
        player:addCurrency('spark_of_eminence', sparks * xi.settings.main.SPARKS_RATE, xi.settings.main.CAP_CURRENCY_SPARKS)
        player:messageBasic(xi.msg.basic.ROE_RECEIVE_SPARKS, sparks * xi.settings.main.SPARKS_RATE, player:getCurrency('spark_of_eminence'))
    end

    if exp > 0 then
        player:addExp(exp * xi.settings.main.EXP_RATE)
    end

    if vouchers > 0 then
        npcUtil.giveItem(player, { { xi.item.COPPER_AMAN_VOUCHER, vouchers } })
    end
end
