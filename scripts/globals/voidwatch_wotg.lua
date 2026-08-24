-----------------------------------
-- Wings of the Goddess Voidwatch storyline -- shared engine
--
-- The nineteen Crystal War quests from Guardian of the Void (80) to Ad Infinitum
-- (98) are ONE linear chain, and the chain order matches the quest id order exactly.
-- They are built from three repeating step shapes rather than nineteen bespoke
-- scripts:
--
--   KILL   defeat a named set of Voidwatch NMs, then have an Atmacite Refiner
--          upgrade your White stratum abyssite.
--   TALK   a single cutscene at a fixed place (Ru'Lude Audience Chamber, the
--          Sauromugue Bulwark Gate, the Pashhow Veridical Conflux) that grants key
--          items, completes the quest and flags the next.
--   ALARUM speak to any Voidwatch Officer of the right era to receive a Voidwatch
--          alarum, which ends one quest and begins the next.
--
-- THE OFFICER IS A UNIFORM COMPONENT. Every Voidwatch Officer in every zone carries
-- the SAME NINE event blocks with identical byte sizes; only the csid numbers differ
-- per zone. The table below was derived by reading each officer's entry table and
-- keying on BLOCK SIZE, not by guessing numbers:
--     12328/12327  the Voidwatch service menu
--     631          the FIRST alarum, "I've received an urgent alarum calling our
--                  best men to arms, and guess whose name is listed front and
--                  center?" (msg 15507). Uniquely identifiable.
--     1377         "Excellent work... Your presence has been requested in the Grand
--                  Duchy once more." (msg 15513)
--     640          "Hold it right there, soldier! A summons just came in from the
--                  Grand Duchy." (msg 15543)
--     600          "We've been looking for you, soldier." (msg 15544)
--     2034         the larger combined block
--
-- WHICH SUMMONS BLOCK BELONGS TO WHICH STEP IS NOT RECOVERABLE FROM THE DUMPS, and
-- it does not need to be. None of the six carries a chain key item in its data[]
-- table, so the abyssites, emblems and alarums are all granted server-side by the
-- Lua below rather than by the event. The csid selects which line of flavour text
-- the player reads; it does not decide whether the quest works. Steps therefore use
-- `first` for the opening alarum, which IS uniquely identified, and `again` for the
-- later ones, which is the block whose text ("...requested in the Grand Duchy once
-- more") matches a repeat summons. If a future in-game probe shows a different
-- variant is canonical for a given step, changing one field in that quest's spec is
-- the whole fix.
--
-- THE ATMACITE REFINER'S MENU IS CLIENT-SIDE MASKED. Each refiner is a single
-- ~23,920-byte program whose option mask is computed in a work var, so the "examine
-- and upgrade your abyssite" line cannot be driven from here. This is the same
-- situation as the Martello towers, and it takes the same established answer:
-- scripts/globals/abyssea/martello.lua drives those with printToPlayer instead of
-- the masked menu, so the upgrade below does too. What bg-wiki actually specifies
-- is the OUTCOME -- which abyssite becomes which -- and that is reproduced exactly.
-----------------------------------
require('scripts/globals/quests')
-----------------------------------

xi = xi or {}
xi.vwChain = xi.vwChain or {}

-- zone -> the officer's nine blocks, identified by block size. See the header.
xi.vwChain.officers =
{
    [xi.zone.SOUTHERN_SAN_DORIA_S]   = { menu = 658,  first = 665,  again = 666,  urgent = 668,  seek = 670,  big = 672  },
    [xi.zone.BATALLIA_DOWNS_S]       = { menu = 26,   first = 28,   again = 29,   urgent = 31,   seek = 33,   big = 35   },
    [xi.zone.BASTOK_MARKETS_S]       = { menu = 80,   first = 82,   again = 83,   urgent = 85,   seek = 87,   big = 89   },
    [xi.zone.ROLANBERRY_FIELDS_S]    = { menu = 9,    first = 11,   again = 12,   urgent = 14,   seek = 16,   big = 18   },
    [xi.zone.WINDURST_WATERS_S]      = { menu = 47,   first = 49,   again = 50,   urgent = 52,   seek = 54,   big = 56   },
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S] = { menu = 16,   first = 18,   again = 19,   urgent = 23,   seek = 25,   big = 29   },
    [xi.zone.BATALLIA_DOWNS]         = { menu = 8,    first = 10,   again = 11,   urgent = 13,   seek = 15,   big = 17   },
    [xi.zone.ROLANBERRY_FIELDS]      = { menu = 7,    first = 9,    again = 10,   urgent = 12,   seek = 14,   big = 16   },
    [xi.zone.SAUROMUGUE_CHAMPAIGN]   = { menu = 8,    first = 10,   again = 11,   urgent = 13,   seek = 15,   big = 17   },
    [xi.zone.QUFIM_ISLAND]           = { menu = 50,   first = 52,   again = 53,   urgent = 55,   seek = 57,   big = 59   },
    [xi.zone.SOUTHERN_SAN_DORIA]     = { menu = 963,  first = 977,  again = 978,  urgent = 981,  seek = 983,  big = 985  },
    [xi.zone.BASTOK_MARKETS]         = { menu = 9,    first = 11,   again = 12,   urgent = 16,   seek = 18,   big = 21   },
    [xi.zone.WINDURST_WATERS]        = { menu = 1024, first = 1035, again = 1036, urgent = 1039, seek = 1041, big = 1043 },
}

-- Shadowreign officers, i.e. the ones bg-wiki calls "past". The rest are present
-- day. Several steps care which era you speak to.
xi.vwChain.shadowreign =
{
    [xi.zone.SOUTHERN_SAN_DORIA_S]   = true,
    [xi.zone.BATALLIA_DOWNS_S]       = true,
    [xi.zone.BASTOK_MARKETS_S]       = true,
    [xi.zone.ROLANBERRY_FIELDS_S]    = true,
    [xi.zone.WINDURST_WATERS_S]      = true,
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S] = true,
}

-- zone -> the refiner's single program. Read the same way as the officers, by taking
-- each refiner's one large block.
xi.vwChain.refiners =
{
    [xi.zone.SOUTHERN_SAN_DORIA_S]   = 657,
    [xi.zone.BATALLIA_DOWNS_S]       = 25,
    [xi.zone.BASTOK_MARKETS_S]       = 79,
    [xi.zone.ROLANBERRY_FIELDS_S]    = 8,
    [xi.zone.WINDURST_WATERS_S]      = 46,
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S] = 15,
    [xi.zone.BATALLIA_DOWNS]         = 7,
    [xi.zone.ROLANBERRY_FIELDS]      = 6,
    [xi.zone.SAUROMUGUE_CHAMPAIGN]   = 7,
    [xi.zone.QUFIM_ISLAND]           = 49,
    [xi.zone.SOUTHERN_SAN_DORIA]     = 962,
    [xi.zone.BASTOK_MARKETS]         = 8,
    [xi.zone.WINDURST_WATERS]        = 1023,
    [xi.zone.TAVNAZIAN_SAFEHOLD]     = 627,
    [xi.zone.WAJAOM_WOODLANDS]       = 24,
    [xi.zone.RABAO]                  = 16,
    [xi.zone.KAZHAM]                 = 316,
    [xi.zone.NORG]                   = 264,
}

--- The csid for one officer role in one zone, or nil if that zone has no officer.
---@param zoneId integer the zone the player is standing in
---@param role string one of menu / first / again / urgent / seek / big
xi.vwChain.officerCsid = function(zoneId, role)
    local entry = xi.vwChain.officers[zoneId]

    if entry == nil then
        return nil
    end

    return entry[role]
end

--- Record one Voidwatch NM kill in the quest's own bitmask.
---@param quest table the Quest object
---@param player CBaseEntity the player credited with the kill
---@param index integer this NM's position in the step's target list
xi.vwChain.markKill = function(quest, player, index)
    local mask = quest:getVar(player, 'Kills')

    quest:setVar(player, 'Kills', bit.bor(mask, bit.lshift(1, index)))
end

--- True once every NM in the step has been defeated.
xi.vwChain.allKilled = function(quest, player, count)
    local full = bit.lshift(1, count) - 1

    return bit.band(quest:getVar(player, 'Kills'), full) == full
end

xi.vwChain.clearKills = function(quest, player)
    quest:setVar(player, 'Kills', 0)
end

--- Build the per-zone mob handlers for a step's target list.
--
--- Voidwatch NMs are alliance content and bg-wiki is explicit that credit is shared,
--- so no killer check is applied: anyone on the step who is present gets the tick.
---@param quest table the Quest object
---@param targets table ordered list of { zone = xi.zone.X, mob = 'Name' }
---@return table zone -> { [mobName] = { onMobDeath = ... } }
xi.vwChain.killHandlers = function(quest, targets)
    local zones = {}

    for index, target in ipairs(targets) do
        local slot = index - 1

        zones[target.zone] = zones[target.zone] or {}
        zones[target.zone][target.mob] =
        {
            onMobDeath = function(mob, player, optParams)
                xi.vwChain.markKill(quest, player, slot)
            end,
        }
    end

    return zones
end

--- Fold the refiner into a step's zone table.
--
--- The refiner's own menu is masked (see the header), so the upgrade is performed
--- here and reported with printToPlayer, matching how martello.lua handles the same
--- problem. `fromKi` is surrendered and `toKi` granted, which is precisely what
--- bg-wiki specifies for each step.
---@param zones table the step's zone table, modified in place
---@param quest table the Quest object
---@param count integer how many NMs the step requires
---@param fromKi integer the abyssite handed in
---@param toKi integer the abyssite handed back
xi.vwChain.addRefiner = function(zones, quest, count, fromKi, toKi)
    for zoneId, _ in pairs(xi.vwChain.refiners) do
        zones[zoneId] = zones[zoneId] or {}
        zones[zoneId]['Atmacite_Refiner'] =
        {
            onTrigger = function(player, npc)
                if
                    not xi.vwChain.allKilled(quest, player, count) or
                    not player:hasKeyItem(fromKi) or
                    player:hasKeyItem(toKi)
                then
                    return
                end

                player:delKeyItem(fromKi)
                npcUtil.giveKeyItem(player, toKi)
                player:printToPlayer('The refiner turns your abyssite over, and the stone drinks in the light until it shines anew.', xi.msg.channel.NS_SAY)

                return true
            end,
        }
    end
end
