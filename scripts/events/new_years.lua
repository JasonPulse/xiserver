-----------------------------------
-- New Year's Celebration (Ganjitsu)
-----------------------------------
-- Battledore children (permanent NPCs, hidden off-season):
-- Jeanparmand  Northern San d'Oria !pos -217.698 0.008 44.619 231
-- Bunta        Bastok Markets      !pos -345.268 -10.004 -153.375 235
-- Pyru-Copyru  Port Windurst       !pos -211.684 -8.194 213.852 240
--
-- Ake & Ome mandragora pairs (permanent NPCs, hidden off-season):
-- Northern San d'Oria !pos 82.250 -0.200 44.000 231
-- Port Bastok         !pos 81.750 0.850 -227.500 236
-- Port Windurst       !pos 221.300 -1.200 226.500 240
--
-- Vendor moogles (dynamic, offset from the egg hunt moogle plazas):
-- Northern San d'Oria !pos -220.135 8.000 48.476 231
-- Bastok Mines        !pos -38.600 -0.001 -105.000 234
-- Windurst Waters     !pos -50.470 -5.391 211.362 238
--
-- Lucky Beast herds (Year of the Sheep): one herd per field zone,
-- anchored a few yalms from an existing NPC row (Field Manual or
-- Telepoint) so they sit on walkable ground near a road.
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.newYears = xi.events.newYears or {}
xi.events.newYears.entities = xi.events.newYears.entities or {}

local event = SeasonalEvent:new('new_years')

-- Default settings
local settings =
{
    ANNOUNCE = false, -- Announce settings on load
    START  = { DAY = 31, MONTH = 12 },
    FINISH = { DAY = 14, MONTH =  1 },

    VAR =
    {
        BATTLEDORE = '[NEWYEAR]BATTLEDORE', -- Battledore already received
        AKE_OME    = '[NEWYEAR]AKEOME',     -- Ake-Ome Spirit already received
    },
}

local function loadSettings(currentTable, settingsName)
    local settingTable = xi.settings.main[settingsName]

    if not settingTable then
        if currentTable.ANNOUNCE then
            print('[NewYears] No settings in main.lua, using default')
        end

        return
    else
        if currentTable.ANNOUNCE then
            print('[NewYears] Loading settings from main.lua')
        end
    end

    -- Load from main settings into current table
    for settingName, _ in pairs(currentTable) do
        if settingTable[settingName] then
            currentTable[settingName] = settingTable[settingName]
        end
    end
end

loadSettings(settings, 'NEW_YEAR')

xi.events.newYears.enabledCheck = function()
    local month = JstMonth()
    local day = JstDayOfTheMonth()

    if month == settings.START.MONTH then
        if day >= settings.START.DAY then
            return true
        end

    elseif month == settings.FINISH.MONTH then
        if day <= settings.FINISH.DAY then
            return true
        end
    end

    return false
end

event:setEnableCheck(xi.events.newYears.enabledCheck)

-----------------------------------
-- Items (all IDs verified in sql/item_basic.sql)
-----------------------------------

local item =
{
    LINKPEARL        = xi.item.LINKPEARL,
    NEW_YEARS_GIFTS  =
    {
        xi.item.NEW_YEARS_GIFT_1,
        xi.item.NEW_YEARS_GIFT_2,
        xi.item.NEW_YEARS_GIFT_3,
        xi.item.NEW_YEARS_GIFT_4,
        xi.item.NEW_YEARS_GIFT_5,
        xi.item.NEW_YEARS_GIFT_6,
        xi.item.NEW_YEARS_GIFT_7,
        xi.item.NEW_YEARS_GIFT_8,
        xi.item.NEW_YEARS_GIFT_9,
    },
    GALETTE_DES_ROIS = xi.item.GALETTE_DES_ROIS,
    BATTLEDORE       = xi.item.BATTLEDORE,
    FIREWORKS        = { xi.item.GOSHIKITENGE, xi.item.POPSTAR, xi.item.CRACKER },
    AKE_OME_SPIRIT   = xi.item.AKE_OME_SPIRIT,
}

local mandragoraCostume = 301 -- Mandragora model, same ID as harvest_festivals costume list

-----------------------------------
-- Lucky Beast herds (Year of the Sheep)
-----------------------------------
-- Lead: Elated Ovis (ram model, look from Rampaging_Ram pool)
-- Followers: Smiling/Ecstatic/Playful Ovis (sheep model, look from Mad_Sheep pool)
-- Positions anchored to an existing npc_list row in each zone (see comments)
-----------------------------------

local ramLook   = '0x0000580100000000000000000000000000000000'
local sheepLook = '0x0000540100000000000000000000000000000000'

-- { rotation, x, y, z } for the herd lead
xi.events.newYears.herds =
{
    [xi.zone.WEST_RONFAURE]         = {  32, -159.752, -60.000,  299.530 }, -- Field Manual anchor (-163.752, -60.000, 295.530)
    [xi.zone.EAST_RONFAURE]         = {  96,   88.802, -59.906,  244.052 }, -- Field Manual anchor (84.802, -59.906, 240.052)
    [xi.zone.LA_THEINE_PLATEAU]     = { 160,  424.000,  19.104,   24.000 }, -- Telepoint anchor (420.000, 19.104, 20.000)
    [xi.zone.VALKURM_DUNES]         = { 224,  137.164,  -7.463,  100.594 }, -- Field Manual anchor (133.164, -7.463, 96.594)
    [xi.zone.JUGNER_FOREST]         = {  32,   69.273,   0.398,  -10.112 }, -- Field Manual anchor (65.273, 0.398, -14.112)
    [xi.zone.BATALLIA_DOWNS]        = {  96, -409.391,  -9.197, -223.871 }, -- Field Manual anchor (-413.391, -9.197, -227.871)
    [xi.zone.NORTH_GUSTABERG]       = { 160,  629.019,  -1.045,  320.154 }, -- Field Manual anchor (625.019, -1.045, 316.154)
    [xi.zone.SOUTH_GUSTABERG]       = { 224,  554.415,  -0.933, -311.455 }, -- Field Manual anchor (550.415, -0.933, -315.455)
    [xi.zone.KONSCHTAT_HIGHLANDS]   = {  32,  224.000,  19.104,  304.000 }, -- Telepoint anchor (220.000, 19.104, 300.000)
    [xi.zone.PASHHOW_MARSHLANDS]    = {  96,  481.439,  24.648,  423.927 }, -- Field Manual anchor (477.439, 24.648, 419.927)
    [xi.zone.ROLANBERRY_FIELDS]     = { 160,  204.404,  24.256,  493.175 }, -- Field Manual anchor (200.404, 24.256, 489.175)
    [xi.zone.BEAUCEDINE_GLACIER]    = { 224,  -21.207, -59.324, -119.423 }, -- Field Manual anchor (-25.207, -59.324, -123.423)
    [xi.zone.XARCABARD]             = {  32,  154.258, -21.047,  -33.256 }, -- Telepoint anchor (150.258, -21.047, -37.256)
    [xi.zone.EASTERN_ALTEPA_DESERT] = {  96,  -57.942,   3.949,  228.900 }, -- Telepoint anchor (-61.942, 3.949, 224.900)
    [xi.zone.WEST_SARUTABARUTA]     = { 160,  293.632,  -4.864,   -1.926 }, -- Field Manual anchor (289.632, -4.864, -5.926)
    [xi.zone.EAST_SARUTABARUTA]     = { 224, -104.115,  -4.649, -522.442 }, -- Field Manual anchor (-108.115, -4.649, -526.442)
    [xi.zone.TAHRONGI_CANYON]       = {  32,  104.000,  35.150,  344.000 }, -- Telepoint anchor (100.000, 35.150, 340.000)
    [xi.zone.BUBURIMU_PENINSULA]    = {  96,  151.125,  -1.017, -181.507 }, -- Field Manual anchor (147.125, -1.017, -185.507)
    [xi.zone.MERIPHATAUD_MOUNTAINS] = { 160, -294.685,  17.047,  429.156 }, -- Field Manual anchor (-298.685, 17.047, 425.156)
    [xi.zone.SAUROMUGUE_CHAMPAIGN]  = { 224,  476.422,  -8.864, -436.169 }, -- Field Manual anchor (472.422, -8.864, -440.169)
    [xi.zone.THE_SANCTUARY_OF_ZITAH] = { 32,  -30.000,   0.057, -146.177 }, -- Field Manual anchor (-34.000, 0.057, -150.177)
    [xi.zone.YUHTUNGA_JUNGLE]       = {  96, -220.526,  -0.298,  501.211 }, -- Field Manual anchor (-224.526, -0.298, 497.211)
    [xi.zone.YHOATOR_JUNGLE]        = { 160, -276.942,   0.597, -140.156 }, -- Telepoint anchor (-280.942, 0.597, -144.156)
    [xi.zone.QUFIM_ISLAND]          = { 224,  183.180, -20.791,  -21.059 }, -- Field Manual anchor (179.180, -20.791, -25.059)
    [xi.zone.WESTERN_ALTEPA_DESERT] = {  32,  450.106,  -1.824,  357.842 }, -- Field Manual anchor (446.106, -1.824, 353.842)
}

-- { packet name, internal name, rotation, x offset, z offset }
local herdFollowers =
{
    { 'Smiling Ovis',  'Smiling_Ovis',   32, -3.0,  1.5 },
    { 'Ecstatic Ovis', 'Ecstatic_Ovis', 224,  3.0,  2.5 },
    { 'Playful Ovis',  'Playful_Ovis',  160, -1.0, -3.0 },
}

-- No sheep-year greeting lines exist in the client DAT (only the horse-year
-- lines at e.g. West Ronfaure 7884-7892), so the herd speaks via printToPlayer.
local herdBuffs =
{
    { xi.effect.PROTECT,      20 },
    { xi.effect.SHELL,        10 },
    { xi.effect.ENTHUNDER,    10 },
    { xi.effect.SHOCK_SPIKES, 10 },
}

xi.events.newYears.onHerdLeadTrigger = function(player, npc)
    npc:facePlayer(player, true)
    player:printToPlayer('Baaah! Baah! (A New Year\'s greeting? It looks very happy!)', xi.msg.channel.NS_SAY, 'Elated Ovis')
end

xi.events.newYears.onHerdFollowerTrigger = function(player, npc)
    npc:facePlayer(player, true)
    player:printToPlayer('Baah! Baaah! (It bounds around you excitedly.)', xi.msg.channel.NS_SAY, npc:getPacketName())
end

xi.events.newYears.onHerdLeadTrade = function(player, npc, trade)
    npc:facePlayer(player, true)

    if
        trade:getGil() > 0 or
        trade:getSlotCount() ~= 1
    then
        player:printToPlayer('Baah? (It tilts its head, confused by the offering.)', xi.msg.channel.NS_SAY, 'Elated Ovis')
        return
    end

    -- Trading a New Year's Gift back only refreshes the blessing (retail quirk)
    local giftTradedBack = false
    for _, giftID in pairs(item.NEW_YEARS_GIFTS) do
        if npcUtil.tradeHas(trade, giftID) then
            giftTradedBack = true
            break
        end
    end

    if not giftTradedBack then
        local roll   = math.random(100)
        local reward = nil

        if roll <= 25 then
            reward = item.NEW_YEARS_GIFTS[math.random(#item.NEW_YEARS_GIFTS)]
        elseif roll <= 40 then
            reward = item.GALETTE_DES_ROIS
        end

        if
            reward and
            not npcUtil.giveItem(player, reward, { fromTrade = true })
        then
            return
        end

        player:tradeComplete()
    end

    local buff = herdBuffs[math.random(#herdBuffs)]
    player:delStatusEffect(buff[1])
    player:addStatusEffect(buff[1], buff[2], 0, 60)
    player:printToPlayer('Baaah! Baah! Baaah! (It bestows a New Year\'s blessing upon you!)', xi.msg.channel.NS_SAY, 'Elated Ovis')
end

-----------------------------------
-- Battledore chain
-----------------------------------
-- dialogBase is the zone dialog ID of 'Huh? Oh, a customer! Happy New
-- Year!'.  The rest of the retail block sits at fixed offsets from it
-- in all three zones (verified against the client DAT dumps).
-----------------------------------

xi.events.newYears.battledore =
{
    [xi.zone.NORTHERN_SAN_DORIA] = { npcID = 17723672, dialogBase = 14671 }, -- Jeanparmand
    [xi.zone.BASTOK_MARKETS]     = { npcID = 17739969, dialogBase =  9720 }, -- Bunta
    [xi.zone.PORT_WINDURST]      = { npcID = 17760469, dialogBase = 13105 }, -- Pyru-Copyru
}

-- Offsets from dialogBase (quotes from Bastok Markets 9720-9790)
local kidMessage =
{
    GREETING       =  0, -- Huh? Oh, a customer! Happy New Year!
    LINKPEARL      =  1, -- What? Who was I talking to just now? Oh, the other day, this really nice old man gave me my very own <linkpearl>...
    PROCESSION     =  2, -- Just now, he was telling me about the weird procession of people walking around outside...
    WANT_GIFT      =  3, -- He also told me that if I give 'em something, they'll give me a <New Year's gift> in return...
    GO_GET         =  4, -- Hey. You're an adventurer, right? ... Go out and get me a <New Year's gift>, ASAP...
    THANKS         =  5, -- Whoa! You really brought me back a <New Year's gift>. Thanks!
    REWARD_CHOICE  =  6, -- I guess you'll be wanting your reward now, huh? Hmmm... How about I give you a choice?
    -- Offset 7 is the retail ${selection-lines} menu; replaced with customMenu
    CALLING        =  9, -- Hold on. I'll see if I can get through. Grandpa has a lot of little friends just like me...
    HI_GRANDPA     = 10, -- Oh, hi Grandpa! Uh-huh... Yeah...
    TOLD_ME        = 14, -- Okay, adventurer. Grandpa told me to tell you this...
    FORTUNE_FIRST  = 15, -- The sable spirit of Diabolos looms in your wake. (11 groups of 4 lines, through offset 58)
    CANDY          = 61, -- Whatever that means. I don't understand half the stuff he says, but I like him because he gives me candy.
    POCKET         = 62, -- I knew it. You adventurers are all alike. Here, take this. It was getting sweaty in my pocket anyway.
    ABOUT_GRANDPA  = 63, -- You want to know about Grandpa? Actually, I don't know if I can tell you much.
    VISITS         = 64, -- He comes to visit sometimes, and gives me presents...
    LOCATION_FIRST = 65, -- Although earlier today on the linkshell he said... (5 variants, offsets 65-69)
    SAME_THING     = 70, -- He said the same thing yesterday, so he may still be in the same place...
}

local fortuneGroups   = 11 -- Diabolos through Bahamut, 4 lines each
local locationVariants = 5

local grandpaQuestion = function(player, npc, dialogBase)
    player:messageText(npc, dialogBase + kidMessage.CALLING)
    player:messageText(npc, dialogBase + kidMessage.HI_GRANDPA)
    player:messageText(npc, dialogBase + kidMessage.TOLD_ME)

    local fortuneBase = dialogBase + kidMessage.FORTUNE_FIRST + 4 * math.random(0, fortuneGroups - 1)
    for line = 0, 3 do
        player:messageText(npc, fortuneBase + line)
    end

    player:messageText(npc, dialogBase + kidMessage.CANDY)
end

local pocketReward = function(player, npc, dialogBase, giftID)
    local reward = item.BATTLEDORE

    if player:getCharVar(settings.VAR.BATTLEDORE) == 1 then
        reward = item.FIREWORKS[math.random(#item.FIREWORKS)]
    end

    if npcUtil.giveItem(player, reward, { fromTrade = true }) then
        -- The trade window has already closed, so the gift is removed here
        player:delItem(giftID, 1)
        player:messageText(npc, dialogBase + kidMessage.POCKET)

        if reward == item.BATTLEDORE then
            player:setCharVar(settings.VAR.BATTLEDORE, 1)
        end
    end
end

local grandpaInfo = function(player, npc, dialogBase)
    player:messageText(npc, dialogBase + kidMessage.ABOUT_GRANDPA)
    player:messageText(npc, dialogBase + kidMessage.VISITS)
    player:messageText(npc, dialogBase + kidMessage.LOCATION_FIRST + math.random(0, locationVariants - 1))
    player:messageText(npc, dialogBase + kidMessage.SAME_THING)
end

xi.events.newYears.onBattledoreTrigger = function(player, npc)
    local data = xi.events.newYears.battledore[player:getZoneID()]
    if not data then
        return
    end

    npc:facePlayer(player, true)
    player:messageText(npc, data.dialogBase + kidMessage.GREETING)
    player:messageSpecial(data.dialogBase + kidMessage.LINKPEARL, item.LINKPEARL)
    player:messageText(npc, data.dialogBase + kidMessage.PROCESSION)
    player:messageSpecial(data.dialogBase + kidMessage.WANT_GIFT, item.NEW_YEARS_GIFTS[1])
    player:messageSpecial(data.dialogBase + kidMessage.GO_GET, item.NEW_YEARS_GIFTS[1])
end

xi.events.newYears.onBattledoreTrade = function(player, npc, trade)
    local data = xi.events.newYears.battledore[player:getZoneID()]
    if not data then
        return
    end

    local giftTraded = nil
    for _, giftID in pairs(item.NEW_YEARS_GIFTS) do
        if npcUtil.tradeHasExactly(trade, giftID) then
            giftTraded = giftID
            break
        end
    end

    if not giftTraded then
        return
    end

    npc:facePlayer(player, true)
    player:messageSpecial(data.dialogBase + kidMessage.THANKS, giftTraded)
    player:messageText(npc, data.dialogBase + kidMessage.REWARD_CHOICE)

    -- The gift is only consumed when the pocket reward is chosen, so the
    -- trade itself is left unconfirmed (items return to the player)
    player:customMenu(
    {
        title   = 'I\'ll...',
        options =
        {
            {
                'Let you ask Grandpa a question.',
                function(playerArg)
                    grandpaQuestion(playerArg, npc, data.dialogBase)
                end,
            },
            {
                'Give you something from my pocket.',
                function(playerArg)
                    if playerArg:hasItem(giftTraded) then
                        pocketReward(playerArg, npc, data.dialogBase, giftTraded)
                    end
                end,
            },
            {
                'Tell you more about Grandpa.',
                function(playerArg)
                    grandpaInfo(playerArg, npc, data.dialogBase)
                end,
            },
        },
    })
end

-----------------------------------
-- Ake & Ome mandragora pair
-----------------------------------
-- No Ake/Ome dialog exists in the client DAT for these zones, so the
-- pair speaks via printToPlayer ('Akemashite' / 'Omedetou')
-----------------------------------

xi.events.newYears.akeOme =
{
    [xi.zone.NORTHERN_SAN_DORIA] = { ake = 17723674, ome = 17723675 },
    [xi.zone.PORT_BASTOK]        = { ake = 17744059, ome = 17744060 },
    [xi.zone.PORT_WINDURST]      = { ake = 17760470, ome = 17760471 },
}

xi.events.newYears.onAkeOmeTrigger = function(player, npc, greeting)
    npc:facePlayer(player, true)
    player:printToPlayer(greeting, xi.msg.channel.NS_SAY, npc:getPacketName())

    if player:getCharVar(settings.VAR.AKE_OME) == 0 then
        if npcUtil.giveItem(player, item.AKE_OME_SPIRIT) then
            player:setCharVar(settings.VAR.AKE_OME, 1)
        end

    elseif
        player:hasItem(item.AKE_OME_SPIRIT) and
        player:canUseMisc(xi.zoneMisc.COSTUME)
    then
        player:addStatusEffect(xi.effect.COSTUME, mandragoraCostume, 0, 3600)
    end
end

xi.events.newYears.onAkeTrigger = function(player, npc)
    xi.events.newYears.onAkeOmeTrigger(player, npc, 'Ake! Akemashite! (It hops about, wishing you a happy new year!)')
end

xi.events.newYears.onOmeTrigger = function(player, npc)
    xi.events.newYears.onAkeOmeTrigger(player, npc, 'Ome! Omedetou! (It hops about, wishing you a happy new year!)')
end

-----------------------------------
-- Vendor moogles (past New Year rewards)
-----------------------------------

-- { rotation, x, y, z }, a few yalms from the egg hunt moogle plazas
local vendorMoogles =
{
    [xi.zone.NORTHERN_SAN_DORIA] = { 128, -220.135,  8.000,   48.476 }, -- !pos -220.135 8.000 48.476 231
    [xi.zone.BASTOK_MINES]       = {   0,  -38.600, -0.001, -105.000 }, -- !pos -38.600 -0.001 -105.000 234
    [xi.zone.WINDURST_WATERS]    = {   0,  -50.470, -5.391,  211.362 }, -- !pos -50.470 -5.391 211.362 238
}

-- { menu label, item ID, price }
local shopStock =
{
    furnishings =
    {
        { 'Kadomatsu (5,000 gil)',       87, 5000  },
        { 'Okadomatsu (10,000 gil)',    100, 10000 },
        { 'Snowman Knight (10,000 gil)', 176, 10000 },
        { 'Snowman Miner (10,000 gil)',  177, 10000 },
        { 'Snowman Mage (10,000 gil)',   178, 10000 },
    },

    equipment =
    {
        { 'Gyokuto Obi (10,000 gil)', 15860, 10000 },
        { 'Snowman Cap (10,000 gil)', 10875, 10000 },
        { 'Janus Guard (10,000 gil)', 10808, 10000 },
    },

    sundries =
    {
        { 'BB Cowbell Alpha (1,000 gil)', 4091, 1000 },
        { 'BB Cowbell Beta (1,000 gil)',  4092, 1000 },
        { 'BB Cowbell Gamma (1,000 gil)', 4093, 1000 },
        { 'Fortune Fruits (777 gil)',     6498, 777  },
    },
}

local buyItem = function(player, itemID, price)
    if player:getGil() < price then
        player:printToPlayer('You do not have enough gil, kupo!', xi.msg.channel.NS_SAY, 'Moogle')
        return
    end

    if npcUtil.giveItem(player, itemID) then
        player:delGil(price)
    end
end

local openShopPage = function(player, title, stock)
    local options = {}

    for _, entry in ipairs(stock) do
        table.insert(options,
        {
            entry[1],
            function(playerArg)
                buyItem(playerArg, entry[2], entry[3])
            end,
        })
    end

    player:customMenu(
    {
        title   = title,
        options = options,
    })
end

xi.events.newYears.onVendorTrigger = function(player, npc)
    npc:facePlayer(player, true)
    player:printToPlayer('Happy New Year, kupo! I\'ve gathered gifts from celebrations past, kupo!', xi.msg.channel.NS_SAY, 'Moogle')

    player:customMenu(
    {
        title   = 'What would you like to see, kupo?',
        options =
        {
            {
                'Festive furnishings.',
                function(playerArg)
                    openShopPage(playerArg, 'Festive furnishings, kupo!', shopStock.furnishings)
                end,
            },
            {
                'New Year\'s finery.',
                function(playerArg)
                    openShopPage(playerArg, 'New Year\'s finery, kupo!', shopStock.equipment)
                end,
            },
            {
                'Fireworks and food.',
                function(playerArg)
                    openShopPage(playerArg, 'Fireworks and food, kupo!', shopStock.sundries)
                end,
            },
        },
    })
end

-----------------------------------
-- Entity spawning
-----------------------------------

local permanentNpcs =
{
    17723672, -- Jeanparmand, Northern San d'Oria
    17739969, -- Bunta, Bastok Markets
    17760469, -- Pyru-Copyru, Port Windurst
    17723674, -- Ake, Northern San d'Oria
    17723675, -- Ome, Northern San d'Oria
    17744059, -- Ake, Port Bastok
    17744060, -- Ome, Port Bastok
    17760470, -- Ake, Port Windurst
    17760471, -- Ome, Port Windurst
}

local function insertHerd(zone, pos)
    local lead = zone:insertDynamicEntity(
    {
        objtype    = xi.objType.NPC,
        name       = 'Elated_Ovis',
        packetName = 'Elated Ovis',
        look       = ramLook,
        x          = pos[2],
        y          = pos[3],
        z          = pos[4],
        rotation   = pos[1],
        onTrigger  = xi.events.newYears.onHerdLeadTrigger,
        onTrade    = xi.events.newYears.onHerdLeadTrade,
        releaseIdOnDisappear = true,
    })

    if lead then
        table.insert(xi.events.newYears.entities, lead:getID())
    end

    for _, follower in ipairs(herdFollowers) do
        local sheep = zone:insertDynamicEntity(
        {
            objtype    = xi.objType.NPC,
            name       = follower[2],
            packetName = follower[1],
            look       = sheepLook,
            x          = pos[2] + follower[4],
            y          = pos[3],
            z          = pos[4] + follower[5],
            rotation   = follower[3],
            onTrigger  = xi.events.newYears.onHerdFollowerTrigger,
            releaseIdOnDisappear = true,
        })

        if sheep then
            table.insert(xi.events.newYears.entities, sheep:getID())
        end
    end
end

local function insertVendorMoogle(zone, pos)
    local npc = zone:insertDynamicEntity(
    {
        objtype    = xi.objType.NPC,
        name       = 'New_Year_Moogle',
        packetName = 'Moogle',
        look       = 82,
        x          = pos[2],
        y          = pos[3],
        z          = pos[4],
        rotation   = pos[1],
        onTrigger  = xi.events.newYears.onVendorTrigger,
        releaseIdOnDisappear = true,
    })

    if npc then
        table.insert(xi.events.newYears.entities, npc:getID())
    end
end

xi.events.newYears.generateEntities = function()
    for zoneID, pos in pairs(xi.events.newYears.herds) do
        local zone = GetZone(zoneID)
        if zone then
            insertHerd(zone, pos)
        end
    end

    for zoneID, pos in pairs(vendorMoogles) do
        local zone = GetZone(zoneID)
        if zone then
            insertVendorMoogle(zone, pos)
        end
    end
end

xi.events.newYears.showEntities = function(enabled)
    if
        enabled and
        #xi.events.newYears.entities == 0
    then
        xi.events.newYears.generateEntities()
    end

    for _, entityID in pairs(xi.events.newYears.entities) do
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
        xi.events.newYears.entities = {}
    end
end

xi.events.newYears.showPermanentNpcs = function(enabled)
    for _, npcID in pairs(permanentNpcs) do
        local npc = GetNPCByID(npcID)
        if npc then
            if enabled then
                npc:setStatus(xi.status.NORMAL)
            else
                npc:setStatus(xi.status.DISAPPEAR)
            end
        end
    end
end

event:setStartFunction(function()
    xi.events.newYears.showEntities(true)
    xi.events.newYears.showPermanentNpcs(true)
end)

event:setEndFunction(function()
    xi.events.newYears.showEntities(false)
    xi.events.newYears.showPermanentNpcs(false)
end)

event:setServerMessage(
    'Happy New Year! Lucky Beast herds are roaming the fields of Vana\'diel -- trade them anything for a blessing.\n' ..
    'Bring a New Year\'s Gift to Jeanparmand (N. San d\'Oria), Bunta (Bastok Markets), or Pyru-Copyru (Port Windurst),\n' ..
    'and say hello to Ake and Ome beside the Odyssean Passages.')

return event
