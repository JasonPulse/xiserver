-----------------------------------
-- Battle on a New Front
-----------------------------------
-- Log ID: 7, Quest ID: 82
-- !addquest 7 82
-----------------------------------
-- Retail (bg-wiki "Battle on a New Front").
-- Step three of the Wings of the Goddess Voidwatch storyline, which runs from
-- Guardian of the Void (80) to Ad Infinitum (98) in quest-id order.
-- |Previous=Drafted by the Duchy  |Next=VW Op. 126: Qufim Incursion
-- |Reward=KI White stratum abyssite III, KI Voidwatcher's emblem: Qufim, 30,000 gil
--   1. "Engage in and complete the 6 Tier I Voidwatch battles in the 3 field areas
--      surrounding Jeuno (present and past)", followed by the six Tier II battles in
--      the dungeons around it.
--   2. "Return to an Atmacite Refiner to have your KI White stratum abyssite examined
--      and upgraded."
--
-- Every notorious monster below was checked against sql/mob_spawn_points.sql and
-- sits in exactly the zone bg-wiki names for it.
--
-- The per-zone officer csid table, the refiner handling, and why the abyssite
-- upgrade is driven with printToPlayer rather than the refiner's own client-side
-- masked menu, are all documented in scripts/globals/voidwatch_wotg.lua.
-----------------------------------
require('scripts/globals/voidwatch_wotg')
-----------------------------------

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.BATTLE_ON_A_NEW_FRONT)

-- Order matters: each entry's position is its bit in the kill mask.
local targets =
{
    { zone = xi.zone.BATALLIA_DOWNS, mob = 'Cherufe' },
    { zone = xi.zone.BATALLIA_DOWNS_S, mob = 'Taweret' },
    { zone = xi.zone.ROLANBERRY_FIELDS, mob = 'Yatagarasu' },
    { zone = xi.zone.ROLANBERRY_FIELDS_S, mob = 'Agathos' },
    { zone = xi.zone.SAUROMUGUE_CHAMPAIGN, mob = 'Goji' },
    { zone = xi.zone.SAUROMUGUE_CHAMPAIGN_S, mob = 'Gugalanna' },
    { zone = xi.zone.THE_ELDIEME_NECROPOLIS, mob = 'Gasha' },
    { zone = xi.zone.THE_ELDIEME_NECROPOLIS_S, mob = 'Giltine' },
    { zone = xi.zone.CRAWLERS_NEST, mob = 'Mellonia' },
    { zone = xi.zone.CRAWLERS_NEST_S, mob = 'Nympha_Eunomia' },
    { zone = xi.zone.GARLAIGE_CITADEL, mob = 'Roly-Poly' },
    { zone = xi.zone.GARLAIGE_CITADEL_S, mob = 'Laidly_Laurence' },
}

local targetCount = 12

--- The step is finished when every NM is down and the refiner has upgraded the abyssite.
local stepIsDone = function(player)
    return xi.vwChain.allKilled(quest, player, targetCount) and
        player:hasKeyItem(xi.ki.WHITE_STRATUM_ABYSSITE_III)
end

local payOut = function(player, csid, option, npc)
    if quest:complete(player) then
        xi.vwChain.clearKills(quest, player)
        npcUtil.giveKeyItem(player, xi.ki.VOIDWATCHERS_EMBLEM_QUFIM)
        npcUtil.giveCurrency(player, 'gil', 30000)
    end
end

local zones = xi.vwChain.killHandlers(quest, targets)

-- bg-wiki: the refiner turns WHITE_STRATUM_ABYSSITE into WHITE_STRATUM_ABYSSITE_III once every
-- battle in the step is done.
xi.vwChain.addRefiner(zones, quest, targetCount, xi.ki.WHITE_STRATUM_ABYSSITE, xi.ki.WHITE_STRATUM_ABYSSITE_III)

-- Any Voidwatch Officer reports the step in. The csid is looked up per zone because
-- every officer carries the same roles under different numbers.
for zoneId, _ in pairs(xi.vwChain.officers) do
    -- Resolved once, at build time: the handler is only registered for a zone that
    -- has an officer, so the closure captures a plain csid rather than looking it
    -- up again on every trigger.
    local officerCsid = xi.vwChain.officerCsid(zoneId, 'again')

    if officerCsid ~= nil then
        zones[zoneId] = zones[zoneId] or {}

        zones[zoneId]['Voidwatch_Officer'] =
        {
            onTrigger = function(player, npc)
                if not stepIsDone(player) then
                    return
                end

                return quest:progressEvent(officerCsid)
            end,
        }

        zones[zoneId].onEventFinish =
        {
            [officerCsid] = payOut,
        }
    end
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
