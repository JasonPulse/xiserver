-----------------------------------
-- Proto-Waypoints: Anastase's geomagnetic fount survey.
--
-- Three quests in Ru'Lude Gardens, each asking the player to find and record a tier
-- of geomagnetic founts scattered across Vana'diel:
--
--   Researchers from the West    4 founts
--   Middle Lands Investigation  11 founts
--   Further Founts              10 founts
--
-- The counts are not our reading of the wiki, they are what Anastase says out loud.
-- Verified on the live client: csid 10215 renders "You have traveled to the 4
-- locations I have requested", 10219 says 11 and 10223 says 10.
--
-- The founts themselves are already placed: 43 `Geomagnetic_Fount` entities exist in
-- npc_list, one per zone, which is why a tier is expressed here as a plain list of
-- zone ids. Recording one is a trigger on that zone's fount.
--
-- Each tier's zone list is transcribed from the Details column of the quest's wiki
-- table, taking the linked zone from each row.
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------

xi = xi or {}
xi.protoWaypoint = xi.protoWaypoint or {}

-- Ordered lists. Position is the bit index in the player's progress mask, so these
-- must never be reordered and must not become keyed tables: Lua's pairs() has no
-- defined order and the mask would shift under us.
xi.protoWaypoint.tiers =
{
    -- Researchers from the West. bg-wiki words these as ports and dwellings rather
    -- than a table, so they come from its walkthrough bullets.
    [1] =
    {
        xi.zone.SELBINA,
        xi.zone.MHAURA,
        xi.zone.RABAO,
        xi.zone.NORG,
    },

    -- Middle Lands Investigation.
    [2] =
    {
        xi.zone.WEST_RONFAURE,
        xi.zone.NORTH_GUSTABERG,
        xi.zone.WEST_SARUTABARUTA,
        xi.zone.LA_THEINE_PLATEAU,
        xi.zone.KONSCHTAT_HIGHLANDS,
        xi.zone.TAHRONGI_CANYON,
        xi.zone.JUGNER_FOREST,
        xi.zone.PASHHOW_MARSHLANDS,
        xi.zone.MERIPHATAUD_MOUNTAINS,
        xi.zone.ATTOHWA_CHASM,
        xi.zone.ULEGUERAND_RANGE,
    },

    -- Further Founts.
    [3] =
    {
        xi.zone.DAVOI,
        xi.zone.BEADEAUX,
        xi.zone.CASTLE_OZTROJA,
        xi.zone.QUICKSAND_CAVES,
        xi.zone.SEA_SERPENT_GROTTO,
        xi.zone.TEMPLE_OF_UGGALEPIH,
        xi.zone.THE_BOYAHDA_TREE,
        xi.zone.OLDTON_MOVALPOLOS,
        xi.zone.RIVERNE_SITE_B01,
        xi.zone.CASTLE_ZVAHL_KEEP,
    },
}

--- Which bit a zone owns within a tier, or nil if that zone is not in it.
---@param tier integer
---@param zoneId integer
---@return integer|nil
xi.protoWaypoint.indexOf = function(tier, zoneId)
    for index, zone in ipairs(xi.protoWaypoint.tiers[tier]) do
        if zone == zoneId then
            return index - 1
        end
    end

    return nil
end

--- True once every fount in the tier has been recorded.
xi.protoWaypoint.tierComplete = function(quest, player, tier)
    local full = bit.lshift(1, #xi.protoWaypoint.tiers[tier]) - 1

    return bit.band(quest:getVar(player, 'Founts'), full) == full
end

--- How many of the tier's founts are recorded, for the progress line.
xi.protoWaypoint.recorded = function(quest, player, tier)
    local mask  = quest:getVar(player, 'Founts')
    local count = 0

    for index = 0, #xi.protoWaypoint.tiers[tier] - 1 do
        if bit.band(mask, bit.lshift(1, index)) ~= 0 then
            count = count + 1
        end
    end

    return count
end

--- Build the per-zone fount handlers for a tier. Each returns nothing so the fount's
--- own script still runs; the SoA mission attunement in geomagnetic_fount.lua shares
--- these entities and must not be shadowed.
---@param quest table
---@param tier integer
---@return table zoneId -> { ['Geomagnetic_Fount'] = handler }
xi.protoWaypoint.fountZones = function(quest, tier)
    local zones = {}

    for index, zoneId in ipairs(xi.protoWaypoint.tiers[tier]) do
        local bitIndex = index - 1

        zones[zoneId] =
        {
            ['Geomagnetic_Fount'] =
            {
                onTrigger = function(player, npc)
                    quest:setVar(player, 'Founts',
                        bit.bor(quest:getVar(player, 'Founts'), bit.lshift(1, bitIndex)))
                end,
            },
        }
    end

    return zones
end
