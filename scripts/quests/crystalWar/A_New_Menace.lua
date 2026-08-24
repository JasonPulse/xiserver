-----------------------------------
-- A New Menace
-----------------------------------
-- Log ID: 7, Quest ID: 87
-- !addquest 7 87
-----------------------------------
-- Retail (bg-wiki "A New Menace").
-- Step eight of the Wings of the Goddess Voidwatch storyline, which runs from
-- Guardian of the Void (80) to Ad Infinitum (98) in quest-id order.
-- |Previous=Re-Drafted by the Duchy  |Next=No Rest for the Weary
-- |Reward=KI White stratum abyssite V, 50,000 gil
--   1. "Engage in and complete the three tier IV Voidwatch battles in field areas
--      around the three nations."
--   2. "Return to any Atmacite Refiner to have your KI White stratum abyssite IV
--      examined and upgraded to KI White stratum abyssite V."
--   3. "Engage in and complete the three tier V Voidwatch battles in the three crag
--      areas."
--
-- Every notorious monster below was checked against sql/mob_spawn_points.sql and
-- sits in exactly the zone bg-wiki names for it.
--
-- ONE EXCEPTION, and it is a real gap rather than something to work around: Gwynn Ap
-- Nudd, which bg-wiki places in Konschtat Highlands, has NO row in
-- sql/mob_spawn_points.sql. It is listed below because the step genuinely requires
-- it, so the tier V leg cannot finish until that NM is placed. Dropping the target to
-- make the quest completable would be a silent downgrade.
--
-- The per-zone officer csid table, the refiner handling, and why the abyssite
-- upgrade is driven with printToPlayer rather than the refiner's own client-side
-- masked menu, are all documented in scripts/globals/voidwatch_wotg.lua.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_NEW_MENACE)

-- Order matters: each entry's position is its bit in the kill mask.
local targets =
{
    { zone = xi.zone.WEST_RONFAURE, mob = 'Lancing_Lamorak' },
    { zone = xi.zone.SOUTH_GUSTABERG, mob = 'Bhishani' },
    { zone = xi.zone.EAST_SARUTABARUTA, mob = 'Rw_Nw_Prt_M_Hrw' },
    { zone = xi.zone.LA_THEINE_PLATEAU, mob = 'Stachysaurus' },
    { zone = xi.zone.KONSCHTAT_HIGHLANDS, mob = 'Gwynn_Ap_Nudd' },
    { zone = xi.zone.TAHRONGI_CANYON, mob = 'Smierc' },
}

local targetCount = 6

--- The step is finished when every NM is down and the refiner has upgraded the abyssite.
local stepIsDone = function(player)
    return xi.vwChain.allKilled(quest, player, targetCount) and
        player:hasKeyItem(xi.ki.WHITE_STRATUM_ABYSSITE_V)
end

local payOut = function(player, csid, option, npc)
    if quest:complete(player) then
        xi.vwChain.clearKills(quest, player)
        npcUtil.giveCurrency(player, 'gil', 50000)
    end
end

local zones = xi.vwChain.killHandlers(quest, targets)

-- bg-wiki: the refiner turns WHITE_STRATUM_ABYSSITE_IV into WHITE_STRATUM_ABYSSITE_V once every
-- battle in the step is done.
xi.vwChain.addRefiner(zones, quest, targetCount, xi.ki.WHITE_STRATUM_ABYSSITE_IV, xi.ki.WHITE_STRATUM_ABYSSITE_V)

-- Any Voidwatch Officer reports the step in. The csid is looked up per zone because
-- every officer carries the same roles under different numbers.
for zoneId, _ in pairs(xi.vwChain.officers) do
    zones[zoneId] = zones[zoneId] or {}

    zones[zoneId]['Voidwatch_Officer'] =
    {
        onTrigger = function(player, npc)
            if not stepIsDone(player) then
                return
            end

            return quest:progressEvent(xi.vwChain.officerCsid(player:getZoneID(), 'again'))
        end,
    }

    zones[zoneId].onEventFinish =
    {
        [xi.vwChain.officerCsid(zoneId, 'again')] = payOut,
    }
end

local acceptedSection =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED
    end,
}

-- Assembled above rather than written inline: the target list drives which zones
-- appear, so writing them out by hand would duplicate the table.
for zoneId, handlers in pairs(zones) do
    acceptedSection[zoneId] = handlers
end

quest.sections = { acceptedSection }

return quest
