-----------------------------------
-- Adventurer Appreciation Campaign
-----------------------------------
-- Southern San d'Oria !pos 56.195 1.999 -25.207 230
-- Northern San d'Oria !pos -224.135 8.000 53.476 231
-- Bastok Mines        !pos -33.600 -0.001 -110.000 234
-- Bastok Markets      !pos -260.440 -12.021 -79.538 235
-- Windurst Waters     !pos -55.470 -5.391 216.362 238
-- Windurst Woods      !pos 104.823 -5.000 -55.745 241
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.advAppreciation = xi.events.advAppreciation or {}
xi.events.advAppreciation.data = xi.events.advAppreciation.data or {}
xi.events.advAppreciation.entities = xi.events.advAppreciation.entities or {}

local event = SeasonalEvent:new('adventurer_appreciation')

-- Default settings
local settings =
{
    ANNOUNCE = false, -- Announce settings on load
    START  = { DAY = 11, MONTH = 5 },
    FINISH = { DAY = 31, MONTH = 5 },

    VAR =
    {
        RING_YEAR      = '[AAC]RING_YEAR',      -- Last year the anniversary gift picks were reset
        GIFT_PICKS     = '[AAC]GIFT_PICKS',     -- Anniversary gifts picked this year (max 2)
        LAST_CLAIM_DAY = '[AAC]LAST_CLAIM_DAY', -- JST yyyymmdd of the last daily present claim/wait
        WAIT_COUNT     = '[AAC]WAIT_COUNT',     -- Consecutive 'I'll wait' days banked (max 3)
        DEATHS         = '[AAC]DEATHS',         -- Census: Number of Times KO'd
        KILLS          = '[AAC]KILLS',          -- Census: Enemies Defeated
    },
}

local function loadSettings(currentTable, settingsName)
    local settingTable = xi.settings.main[settingsName]

    if not settingTable then
        if currentTable.ANNOUNCE then
            print('[AdvAppreciation] No settings in main.lua, using default')
        end

        return
    else
        if currentTable.ANNOUNCE then
            print('[AdvAppreciation] Loading settings from main.lua')
        end
    end

    -- Load from main settings into current table
    for settingName, _ in pairs(currentTable) do
        if settingTable[settingName] then
            currentTable[settingName] = settingTable[settingName]
        end
    end
end

loadSettings(settings, 'ADV_APPRECIATION')

xi.events.advAppreciation.enabledCheck = function()
    local month = JstMonth()
    local day = JstDayOfTheMonth()

    if month == settings.START.MONTH then
        if
            day >= settings.START.DAY and
            day <= settings.FINISH.DAY
        then
            return true
        end

    elseif month == settings.FINISH.MONTH then
        if day <= settings.FINISH.DAY then
            return true
        end
    end

    return false
end

event:setEnableCheck(xi.events.advAppreciation.enabledCheck)

-----------------------------------
-- Data
-----------------------------------
-- dialogBase is the zone dialog ID of 'Vana'diel is abuzz with
-- "Adventurer Appreciation" fever, kupo!'.  The rest of the retail
-- campaign block sits at fixed offsets from it in all six zones.
-----------------------------------

xi.events.advAppreciation.data =
{
    [xi.zone.SOUTHERN_SAN_DORIA] =
    {
        moogle     = { 194, 56.195, 1.999, -25.207 }, -- !pos 56.195 1.999 -25.207 230
        dialogBase = 8961,
    },

    [xi.zone.NORTHERN_SAN_DORIA] =
    {
        moogle     = { 128, -224.135, 8.000, 53.476 }, -- !pos -224.135 8.000 53.476 231
        dialogBase = 12115,
    },

    [xi.zone.BASTOK_MINES] =
    {
        moogle     = { 0, -33.600, -0.001, -110.000 }, -- !pos -33.600 -0.001 -110.000 234
        dialogBase = 11123,
    },

    [xi.zone.BASTOK_MARKETS] =
    {
        moogle     = { 40, -260.440, -12.021, -79.538 }, -- !pos -260.440 -12.021 -79.538 235
        dialogBase = 7755,
    },

    [xi.zone.WINDURST_WATERS] =
    {
        moogle     = { 0, -55.470, -5.391, 216.362 }, -- !pos -55.470 -5.391 216.362 238
        dialogBase = 9151,
    },

    [xi.zone.WINDURST_WOODS] =
    {
        moogle     = { 161, 104.823, -5.000, -55.745 }, -- !pos 104.823 -5.000 -55.745 241
        dialogBase = 8761,
    },
}

local messageOffset =
{
    ABUZZ          = 0,  -- Vana'diel is abuzz with "Adventurer Appreciation" fever, kupo!
    JOURNAL        = 1,  -- We moogles have prepared some nice little goodies and gathered lots of top-secret information on adventurer activity, kupo! Let me check my journal for your statistical data...
    NUTSHELL       = 4,  -- There's your adventuring life in a nutshell!
    NUTSHELL_GIFT  = 5,  -- There's your adventuring life in a nutshell! And this time, there's an extra-special anniversary present involved! ...
    PICKS_PLURAL   = 6,  -- Take a look--and to think, you can select <number> more amazing anniversary items!
    PICKS_SINGLE   = 7,  -- Take a look--and to think, you can select <number> more amazing anniversary item!
    GIFT_LATER     = 9,  -- Ah, I understand. With some many goodies to choose from, it's no surprise that you'd want to think about it a bit more. I'll be here once you've decided, kupo.
    PRESENT_INTRO1 = 13, -- You have the choice to either receive your present now, or "wait" to build up the suspense, kupo!
    PRESENT_INTRO2 = 14, -- If you choose to wait, you might find yourself receiving an even better present, kupo.
    TAKE_TIME      = 16, -- Take all the time you need, and talk to me when you're ready, kupo!
    PRESENT_HERE   = 17, -- Here's your present, kupo!
    PATIENT_ONE    = 18, -- Kupopopo! A patient one! Let's see how long you can wait before the suspense finally gets to you, kupo!
}

-----------------------------------
-- Anniversary gifts (pick 2 per year, retail 2016+ list)
-----------------------------------

local anniversaryGifts =
{
    { id = 27556, name = 'Echad ring'    },
    { id = 27557, name = 'Trizek ring'   },
    { id = 26164, name = 'Caliber ring'  },
    { id = 26165, name = 'Facility ring' },
    { id = 6412,  name = 'Leaf bench'    },
    { id = 6413,  name = 'Astral cube'   },
}

-----------------------------------
-- Daily present prize pool
-----------------------------------
-- rare  : replaced by fireworks when already owned
-- junk  : removed from the pool once the player has waited
-- scale : stack size grows with banked waits
-----------------------------------

local prizePool =
{
    { id = 193,   rare = true  }, -- adventuring_certificate
    { id = 13218, rare = true  }, -- bronze_moogle_belt
    { id = 13217, rare = true  }, -- silver_moogle_belt
    { id = 13216, rare = true  }, -- gold_moogle_belt
    { id = 15541, rare = true  }, -- homing_ring
    { id = 15542, rare = true  }, -- return_ring
    { id = 17074, rare = true  }, -- chocobo_wand
    { id = 1514,  junk = true  }, -- chocobo_ticket
    { id = 1789               },  -- free_chocopass
    { id = 5441,  scale = true }, -- angelwing
    { id = 5936,  scale = true }, -- mog_missile
    { id = 5937,  scale = true }, -- bubble_breeze
    { id = 5934,  junk = true  }, -- chocobiscuit
    { id = 5935,  junk = true  }, -- bowl_of_moogurt
    { id = 13181, rare = true  }, -- federation_stables_scarf
    { id = 13179, rare = true  }, -- kingdom_stables_collar
    { id = 13180, rare = true  }, -- republic_stables_medal
    { id = 18842, rare = true  }, -- nomad_moogle_rod
    { id = 281,   rare = true  }, -- atomos_statue
    { id = 8711               },  -- copper_a.m.a.n._voucher
}

local fireworks =
{
    4169, -- little_comet
    5725, -- goshikitenge
}

-- Stack size for scaling prizes by banked waits (0 to 3)
local scaleQuantity = { 1, 12, 25, 50 }

-----------------------------------
-- Helpers
-----------------------------------

local jstToday = function()
    return JstYear() * 10000 + JstMonth() * 100 + JstDayOfTheMonth()
end

local moogleSay = function(player, text)
    player:printToPlayer(text, xi.msg.channel.SAY, 'Moogle')
end

local getDialogBase = function(player)
    return xi.events.advAppreciation.data[player:getZoneID()].dialogBase
end

-----------------------------------
-- Census readout
-----------------------------------
-- Retail shows eight lifetime counters.  Only KO's and kills can be
-- tracked from Lua (via charvars fed by global death/kill hooks), so
-- only those lines and playtime are displayed here.
-----------------------------------

local showCensus = function(player, npc)
    local base = getDialogBase(player)

    player:messageText(npc, base + messageOffset.ABUZZ)
    player:messageText(npc, base + messageOffset.JOURNAL)

    local playtime = player:getPlaytime()
    local days     = math.floor(playtime / 86400)
    local hours    = math.floor(playtime % 86400 / 3600)
    local minutes  = math.floor(playtime % 3600 / 60)

    moogleSay(player, string.format('Number of Times KO\'d: %d.', player:getCharVar(settings.VAR.DEATHS)))
    moogleSay(player, string.format('Enemies Defeated: %d.', player:getCharVar(settings.VAR.KILLS)))
    moogleSay(player, string.format('Total Play Time: %d days, %d hours, %d minutes.', days, hours, minutes))
end

-----------------------------------
-- Anniversary gift picks
-----------------------------------

local openGiftMenu

local selectGift = function(player, npc, gift)
    -- Owning one blocks picking it again
    if player:hasItem(gift.id) then
        return
    end

    if npcUtil.giveItem(player, gift.id) then
        local picks = player:getCharVar(settings.VAR.GIFT_PICKS) + 1
        player:setCharVar(settings.VAR.GIFT_PICKS, picks)

        if picks < 2 then
            player:timer(50, function(playerArg)
                openGiftMenu(playerArg, npc)
            end)
        end
    end
end

-- Returns true if the menu was shown
openGiftMenu = function(player, npc)
    local remaining = 2 - player:getCharVar(settings.VAR.GIFT_PICKS)

    if remaining <= 0 then
        return false
    end

    local options = {}

    for _, gift in pairs(anniversaryGifts) do
        if not player:hasItem(gift.id) then
            table.insert(options,
            {
                gift.name,
                function(playerArg)
                    selectGift(playerArg, npc, gift)
                end,
            })
        end
    end

    -- Player already owns everything on offer
    if #options == 0 then
        player:setCharVar(settings.VAR.GIFT_PICKS, 2)
        return false
    end

    local base = getDialogBase(player)

    if remaining > 1 then
        player:messageSpecial(base + messageOffset.PICKS_PLURAL, remaining)
    else
        player:messageSpecial(base + messageOffset.PICKS_SINGLE, remaining)
    end

    player:customMenu(
    {
        title   = 'Pick your Vana\'versary gifts, kupo!',
        options = options,

        onCancelled = function(playerArg)
            playerArg:messageText(npc, base + messageOffset.GIFT_LATER)
        end,
    })

    return true
end

-----------------------------------
-- Daily present
-----------------------------------

local givePresent = function(player, npc)
    local base = getDialogBase(player)

    if player:getFreeSlotsCount() == 0 then
        moogleSay(player, 'You cannot obtain the present, kupo. Make room in your inventory and come back!')
        return
    end

    local waitCount = utils.clamp(player:getCharVar(settings.VAR.WAIT_COUNT), 0, 3)
    local pool = {}

    for _, prize in pairs(prizePool) do
        if
            waitCount == 0 or
            not prize.junk
        then
            table.insert(pool, prize)
        end
    end

    local prize     = pool[math.random(#pool)]
    local rewardID  = prize.id
    local rewardQty = 1

    if prize.scale then
        rewardQty = scaleQuantity[waitCount + 1]
    end

    -- Rare prizes already owned become a fistful of fireworks instead
    if
        prize.rare and
        player:hasItem(prize.id)
    then
        rewardID  = fireworks[math.random(#fireworks)]
        rewardQty = 5 + 10 * waitCount
    end

    player:messageText(npc, base + messageOffset.PRESENT_HERE)

    if npcUtil.giveItem(player, { { rewardID, rewardQty } }) then
        player:setCharVar(settings.VAR.WAIT_COUNT, 0)
        player:setCharVar(settings.VAR.LAST_CLAIM_DAY, jstToday())
    end
end

local waitForPresent = function(player, npc)
    local base      = getDialogBase(player)
    local waitCount = math.min(player:getCharVar(settings.VAR.WAIT_COUNT) + 1, 3)

    player:setCharVar(settings.VAR.WAIT_COUNT, waitCount)
    player:setCharVar(settings.VAR.LAST_CLAIM_DAY, jstToday())
    player:messageText(npc, base + messageOffset.PATIENT_ONE)
end

local openPresentMenu = function(player, npc)
    local base = getDialogBase(player)

    player:messageText(npc, base + messageOffset.PRESENT_INTRO1)
    player:messageText(npc, base + messageOffset.PRESENT_INTRO2)

    player:customMenu(
    {
        title   = 'What will you do, kupo?',
        options =
        {
            {
                'Lemme think, kupo.',
                function(playerArg)
                    playerArg:messageText(npc, base + messageOffset.TAKE_TIME)
                end,
            },
            {
                'Gimme my present, kupo!',
                function(playerArg)
                    givePresent(playerArg, npc)
                end,
            },
            {
                'I\'ll wait, kupo.',
                function(playerArg)
                    waitForPresent(playerArg, npc)
                end,
            },
        },

        onCancelled = function(playerArg)
            playerArg:messageText(npc, base + messageOffset.TAKE_TIME)
        end,
    })
end

-----------------------------------
-- Moogle event handlers
-----------------------------------

xi.events.advAppreciation.onTrigger = function(player, npc)
    local base = getDialogBase(player)

    npc:facePlayer(player, true)
    showCensus(player, npc)

    -- New campaign year resets the anniversary gift picks
    if player:getCharVar(settings.VAR.RING_YEAR) < JstYear() then
        player:setCharVar(settings.VAR.RING_YEAR, JstYear())
        player:setCharVar(settings.VAR.GIFT_PICKS, 0)
    end

    if player:getCharVar(settings.VAR.GIFT_PICKS) < 2 then
        player:messageText(npc, base + messageOffset.NUTSHELL_GIFT)

        if openGiftMenu(player, npc) then
            return
        end
    else
        player:messageText(npc, base + messageOffset.NUTSHELL)
    end

    if player:getCharVar(settings.VAR.LAST_CLAIM_DAY) >= jstToday() then
        moogleSay(player, 'You\'ve already received today\'s present, kupo! Come back tomorrow!')
        return
    end

    openPresentMenu(player, npc)
end

-----------------------------------
-- Show/hide Moogles
-----------------------------------

local function insertMoogle(zone, pos)
    local npc = zone:insertDynamicEntity({
        objtype       = xi.objType.NPC,
        name          = 'Adv_App_Moogle',
        packetName    = 'Moogle',
        look          = 82,
        x             = pos[2],
        y             = pos[3],
        z             = pos[4],
        rotation      = pos[1],
        onTrigger     = xi.events.advAppreciation.onTrigger,
        releaseIdOnDisappear = true,
    })

    table.insert(xi.events.advAppreciation.entities, npc:getID())
end

xi.events.advAppreciation.generateEntities = function()
    for zoneID, data in pairs(xi.events.advAppreciation.data) do
        local zone = GetZone(zoneID)
        if zone then
            insertMoogle(zone, data.moogle)
        end
    end
end

xi.events.advAppreciation.showEntities = function(enabled)
    if
        enabled and
        #xi.events.advAppreciation.entities == 0
    then
        xi.events.advAppreciation.generateEntities()
    end

    for _, entityID in pairs(xi.events.advAppreciation.entities) do
        local entity = GetNPCByID(entityID)
        if entity then
            if enabled then
                entity:setStatus(xi.status.NORMAL)
            else
                entity:setStatus(xi.status.INVISIBLE)
            end
        end
    end

    if not enabled then
        xi.events.advAppreciation.entities = {}
    end
end

event:setStartFunction(function()
    xi.events.advAppreciation.showEntities(true)
end)

event:setEndFunction(function()
    xi.events.advAppreciation.showEntities(false)
end)

event.serverMessage =
    'The Adventurer Appreciation Campaign is underway! Visit the Records and Statistics Moogles ' ..
    'in the six nation cities for your Vana\'versary gifts and a daily present, kupo!'

return event
