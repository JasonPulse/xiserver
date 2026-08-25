-----------------------------------
-- A World in Flux
-----------------------------------
-- Log ID: 7, Quest ID: 89
-- !addquest 7 89
-----------------------------------
-- Retail (bg-wiki "A World in Flux").
-- Step ten of the Wings of the Goddess Voidwatch storyline, which runs from
-- Guardian of the Void (80) to Ad Infinitum (98) in quest-id order.
-- |Previous=No Rest for the Weary  |Next=Between a Rock and Rift
-- |Reward=30,000 gil
--   1. "Engage in and complete the three tier VI Voidwatch battles in the following
--      past areas."
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

local quest = Quest:new(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.A_WORLD_IN_FLUX)

-- Order matters: each entry's position is its bit in the kill mask.
local targets =
{
    { zone = xi.zone.VUNKERL_INLET_S, mob = 'Gaunab' },
    { zone = xi.zone.GRAUBERG_S, mob = 'Ocythoe' },
    { zone = xi.zone.FORT_KARUGO_NARUGO_S, mob = 'Kalasutrax' },
}

local targetCount = 3

--- The step is finished when every NM is down.
local stepIsDone = function(player)
    return xi.vwChain.allKilled(quest, player, targetCount)
end

local payOut = function(player, csid, option, npc)
    if quest:complete(player) then
        xi.vwChain.clearKills(quest, player)
        npcUtil.giveCurrency(player, 'gil', 30000)
    end
end

local zones = xi.vwChain.killHandlers(quest, targets)

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
