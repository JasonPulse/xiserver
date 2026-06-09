-----------------------------------
-- Ambuscade
-----------------------------------
-- Ambuscade_Tome : !pos -28.030 -15.500 52.279 249
-- Gorpa-Masorpa  : !pos -27.584 -15.990 52.565 249
-----------------------------------
-- local mhauraID = require('scripts/zones/Mhaura/IDs')
-- local maquetteID = zones[xi.zone.MAQUETTE_ABDHALJS_LEGION_B]
-----------------------------------
xi = xi or {}
xi.ambuscade = {}

local startingIntenseDifficulty = 119
local startingRegularDifficulty = 109

-- Tables organised by difficulty (VE, E, N, D, VD)
local intenseHallmarks = { 200, 600, 1200, 2400, 3600 }
-- local regularHallmarks = { 100, 150,  200,  250,  300 }

-- Gallantry is later multiplied by the size of your party
local intenseGallantry = { 20, 80, 180, 240, 300 }
-- local regularGallantry = { 10, 15,  20,  25,  30 }

-----------------------------------
-- Monthly rotation (Earth-month, cycles every 24 months).
--
-- Retail rotates Ambuscade NMs roughly monthly. The actual mob spawning in
-- the instance is still TODO (Maquette_Abdhaljs_Legion_B needs mob_groups
-- per family), but exposing the current rotation lets player-facing scripts
-- and future instance logic resolve "what's up this month?" deterministically.
--
-- Order pulled from bg-wiki's documented rotation history.
-----------------------------------
xi.ambuscade.rotation =
{
    'Lamia',       'Fomor',         'Velkk',     'Antica',
    'Tonberry',    'Sahagin',       'Qiqirn',    'Meeble',
    'Qutrub',      'Dullahan',      'Moogle',    'Magic_Mamool',
    'Ironclad',    'Doppleganger',  'Corse',     'Goblin',
    'Orc',         'Quadav',        'Yagudo',    'Gigas',
    'Mamool',      'Troll',         'Frog',      'Soulflayer',
}

-- Returns this month's rotation family name (string). Uses Vana'diel year/
-- month for a deterministic, server-time-driven cycle (one entry per
-- Vana'diel month; cycles every 24 in-game months).
xi.ambuscade.getCurrentRotation = function()
    local vYear  = VanadielYear()
    local vMonth = VanadielMonth()
    local index  = ((vYear * 12 + vMonth) % #xi.ambuscade.rotation) + 1
    return xi.ambuscade.rotation[index]
end

-----------------------------------
-- Simplified shop. Retail Gorpa-Masorpa uses a multi-tab menu (Hallmarks,
-- Total Hallmarks, Gallantry) with on-the-fly option packing that we can't
-- replicate without verified CSID 386 mechanics. Instead we follow the same
-- CharVar-pin pattern as Coalition_Edify_Target / Atma_Selection:
--
--   1. Player sets `Ambuscade_Item_Selection` CharVar to an item id from
--      xi.ambuscade.shop below (e.g. `!setvar Ambuscade_Item_Selection 9220`
--      for a Spool of Abdhaljs Thread).
--   2. Player triggers Gorpa-Masorpa. If they've earned the right currency,
--      the item is granted and the cost deducted; otherwise printToPlayer
--      explains the shortfall.
--
-- Currency types: 'current_hallmarks' (resets monthly in retail; we treat
-- it the same as total here), 'total_hallmarks' (lifetime), or 'gallantry'.
-----------------------------------
xi.ambuscade.shop =
{
    -- [item id]                              = { currency, cost,  label }
    [xi.item.SPOOL_OF_ABDHALJS_THREAD]        = { 'current_hallmarks',  100, 'Abdhaljs Thread' },
    [xi.item.PINCH_OF_ABDHALJS_DUST]          = { 'current_hallmarks',  100, 'Abdhaljs Dust' },
    [xi.item.BOTTLE_OF_ABDHALJS_SAP]          = { 'current_hallmarks',  200, 'Abdhaljs Sap' },
    [xi.item.POT_OF_ABDHALJS_DYE]             = { 'current_hallmarks',  800, 'Abdhaljs Dye' },
    [xi.item.CONTAINER_OF_ABDHALJS_RESIN]     = { 'current_hallmarks', 1500, 'Abdhaljs Resin' },
    [xi.item.AMBUSCADE_VOUCHER_WEAPON]        = { 'current_hallmarks', 1500, 'Ambuscade Voucher: Weapon' },
    [xi.item.ABDHALJS_NUGGETS]                = { 'current_hallmarks', 1500, 'Abdhaljs Nuggets' },
    [xi.item.ABDHALJS_GEM]                    = { 'current_hallmarks', 2500, 'Abdhaljs Gem' },
    [xi.item.ABDHALJS_ANIMA]                  = { 'current_hallmarks', 4000, 'Abdhaljs Anima' },
    [xi.item.CHUNK_OF_ABDHALJS_MATTER]        = { 'current_hallmarks', 6000, 'Abdhaljs Matter' },
    [xi.item.AMBUSCADE_VOUCHER_HEAD]          = { 'gallantry',  800, 'Ambuscade Voucher: Head' },
    [xi.item.AMBUSCADE_VOUCHER_HANDS]         = { 'gallantry',  800, 'Ambuscade Voucher: Hands' },
    [xi.item.AMBUSCADE_VOUCHER_FEET]          = { 'gallantry',  800, 'Ambuscade Voucher: Feet' },
    [xi.item.AMBUSCADE_VOUCHER_LEGS]          = { 'gallantry', 1200, 'Ambuscade Voucher: Legs' },
    [xi.item.AMBUSCADE_VOUCHER_BODY]          = { 'gallantry', 1200, 'Ambuscade Voucher: Body' },
    [xi.item.AMBUSCADE_VOUCHER_BACK]          = { 'gallantry', 1500, 'Ambuscade Voucher: Back' },
}

local ambuscadeItemPinVar = 'Ambuscade_Item_Selection'

local function tryShopPurchase(player)
    local pinned = player:getCharVar(ambuscadeItemPinVar)
    if pinned == 0 then
        return false
    end

    local entry = xi.ambuscade.shop[pinned]
    if not entry then
        player:printToPlayer(string.format('Ambuscade_Item_Selection %d is not on the menu. See scripts/globals/ambuscade.lua xi.ambuscade.shop.', pinned))
        return true
    end

    local currency, cost, label = entry[1], entry[2], entry[3]
    if player:getCurrency(currency) < cost then
        player:printToPlayer(string.format('You need %d %s to obtain a %s.', cost, currency, label))
        return true
    end

    if not npcUtil.giveItem(player, pinned) then
        return true
    end

    player:delCurrency(currency, cost)
    player:printToPlayer(string.format('You obtain a %s (%d %s spent).', label, cost, currency))
    return true
end

-----------------------------------
-- Gorpa-Masorpa
-----------------------------------
xi.ambuscade.onTradeGorpaMasorpa = function(player, npc, trade)
    if player:getEminenceCompleted(499) then
        -- TODO
    end
end

xi.ambuscade.onTriggerGorpaMasorpa = function(player, npc)
    -- RoE Record #499 - Stepping into an Ambuscade
    if player:getEminenceCompleted(499) then
        -- Simplified shop attempt first. If pinned, this handles its own
        -- messaging and returns true so we skip the broken menu event.
        if tryShopPurchase(player) then
            return
        end

        -- local hideRewards              = 1
        -- local hideAmbusade             = 2
        -- local hideNothingInParticular  = 4
        local mainMenuOptions = 0 -- Made up of above options

        local currentHallmarks = player:getCurrency('current_hallmarks')
        local totalHallmarks = player:getCurrency('total_hallmarks')
        local gallantry = player:getCurrency('gallantry')

        -- Regular menu (still stubbed for purchases; the shop pin above is
        -- the working acquisition path until CSID 386 option packing is
        -- captured in-game).
        player:startEvent(386, mainMenuOptions, currentHallmarks, totalHallmarks, 0, 8, gallantry, 0, 0)
    else
        if player:getEminenceProgress(499) then
            -- Intro CS
            player:startEvent(385)
        else
            -- Reminder to set RoE
            player:startEvent(384)
        end
    end
end

xi.ambuscade.onEventUpdateGorpaMasorpa = function(player, csid, option, npc)
    if csid == 386 then
        -- Present Hallmarks menu
        if option == 1 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- ?
        elseif option == 2 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- Present Total Hallmarks menu
        elseif option == 5 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- Update Hallmarks and Total Hallmarks menu
        elseif option == 6 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- Present Gallantry menu
        elseif option == 9 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- Update Gallantry menu
        elseif option == 10 then
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        -- Update player
        else
            player:updateEvent(0, 0, 0, 0, 0, 0, 0, 0)
        end
    end
end

xi.ambuscade.onEventFinishGorpaMasorpa = function(player, csid, option, npc)
    if csid == 385 then
        xi.roe.onRecordTrigger(player, 499)
    end
end

-----------------------------------
-- Ambuscade Tome
-----------------------------------
xi.ambuscade.onTradeTome = function(player, npc, trade)
end

xi.ambuscade.onTriggerTome = function(player, npc)
    -- local hideNoAmbuscadeForNow = 1
    -- local hideIntenseAmbuscade = not player:hasKeyItem(xi.ki.AMBUSCADE_PRIMER_VOLUME_ONE) and 2 or 0
    -- local hideRegularAmbuscade = not player:hasKeyItem(xi.ki.AMBUSCADE_PRIMER_VOLUME_TWO) and 4 or 0
    -- local hideLightAmbuscade = 8
    -- local hideToggleAutoTransport = 16

    -- NOTE: Hard coded for now
    local menuOptions = 4 + 8

    local currentPage = 735
    local arg5 = 5
    local arg6 = 0
    local arg7 = 0
    local arg8 = 0

    -- Surface the current rotation so future instance logic can dispatch.
    -- Players see no in-game effect from this yet; visible via /pos checks
    -- or `print(xi.ambuscade.getCurrentRotation())` from a GM hook.
    player:setLocalVar('AmbuscadeRotation', 1) -- placeholder until per-family mob lists exist

    -- Register
    player:startEvent(374, menuOptions, startingIntenseDifficulty, startingRegularDifficulty, currentPage, arg5, arg6, arg7, arg8)

    -- Enter
    --player:startEvent(378)
end

xi.ambuscade.onEventUpdateTome = function(player, csid, option, npc)
    -- Options
    -- Intense VD : 1
    -- Intense D  : 2
    -- Intense N  : 3
    -- Intense E  : 4
    -- Intense VE : 5
    -- Regular VD : 6
    -- Regular D  : 7
    -- Regular N  : 8
    -- Regular E  : 9
    -- Regular VE : 10
    -- Light      : 11
    if csid == 374 then
        --TODO
    end
end

xi.ambuscade.onEventFinishTome = function(player, csid, option, npc)
    if csid == 374 and option == 5 then
        player:createInstance(30000)
    elseif csid == 378 then
        -- TODO
    end
end

-----------------------------------
-- Ambuscade Tome
-----------------------------------
xi.ambuscade.onInstanceComplete = function(instance)
    local chars    = instance:getChars()
    local numChars = #chars
    local difficulty = 1 -- TODO
    --local version = 1 -- 1: Intense, 2: Regular -- TODO
    for _, player in pairs(chars) do
        -- Hallmarks -- TODO: Message
        local hallmarksEarned = intenseHallmarks[difficulty] * numChars
        player:addCurrency('current_hallmarks', hallmarksEarned)

        -- Total Hallmarks -- TODO: Message
        player:addCurrency('total_hallmarks', hallmarksEarned)

        -- Gallantry -- TODO: Message
        if numChars > 1 then
            local multiplier = numChars - 1
            player:addCurrency('gallantry', intenseGallantry[difficulty] * multiplier)
        end

        -- Remove KI
        -- TODO: Message
        if difficulty == 1 then
            player:delKeyItem(xi.ki.AMBUSCADE_PRIMER_VOLUME_ONE)
        elseif difficulty == 2 then
            player:delKeyItem(xi.ki.AMBUSCADE_PRIMER_VOLUME_TWO)
        end

        -- TODO: Remove Abdhaljs Seal
        --v:delStatusEffect(xi.effect.ABDHALJS_SEAL)

        -- Exit event
        player:startEvent(10001)
    end
end

xi.ambuscade.onInstanceFailure = function(instance)
    local chars = instance:getChars()
    for _, player in pairs(chars) do
        player:startEvent(10001)
    end
end
