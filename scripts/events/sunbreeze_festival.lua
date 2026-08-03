-----------------------------------
-- Sunbreeze Festival
-----------------------------------
-- Goldfish ponds (permanent NPCs in npc_list, hidden outside the event):
-- West Ronfaure     Saradorial       !pos -399.671 -9.999 -438.910 100
-- South Gustaberg   Fish Eyes        !pos -444.459 40.106 -390.885 107
-- East Sarutabaruta Kesha Shopehllok !pos -22.316 -1.790 -50.815 116
-- Rabao             Mei              !pos -37.235 7.999 54.467 247
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.sunbreeze = xi.events.sunbreeze or {}
xi.events.sunbreeze.entities = xi.events.sunbreeze.entities or {}

local event = SeasonalEvent:new('sunbreeze_festival')

-- Default settings
local settings =
{
    ANNOUNCE = false, -- Announce settings on load
    START  = { DAY = 25, MONTH = 7 },
    FINISH = { DAY = 31, MONTH = 8 },

    VAR =
    {
        SCOOP_POINTS = '[SUNBREEZE]SCOOP_POINTS',
        HAS_BASKET   = '[SUNBREEZE]HAS_BASKET',
        DAILY_GIFT   = '[SUNBREEZE]DAILY_GIFT',
    },

    SCOOP_PRICE = 100, -- Gil cost of one super scoop
}

local function loadSettings(currentTable, settingsName)
    local settingTable = xi.settings.main[settingsName]

    if not settingTable then
        if currentTable.ANNOUNCE then
            print('[Sunbreeze] No settings in main.lua, using default')
        end

        return
    else
        if currentTable.ANNOUNCE then
            print('[Sunbreeze] Loading settings from main.lua')
        end
    end

    -- Load from main settings into current table
    for settingName, _ in pairs(currentTable) do
        if settingTable[settingName] then
            currentTable[settingName] = settingTable[settingName]
        end
    end
end

loadSettings(settings, 'SUNBREEZE')

xi.events.sunbreeze.enabledCheck = function()
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

event:setEnableCheck(xi.events.sunbreeze.enabledCheck)

-----------------------------------
-- Items (verified against sql/item_basic.sql)
-----------------------------------

local items =
{
    SUPER_SCOOP      = 17003,
    GOLDFISH_BASKET  = 17013,
    TINY_GOLDFISH    = 4310,
    BLACK_BUBBLE_EYE = 4311,
    LIONHEAD         = 4312,
    PEARLSCALE       = 5714,
    CALICO_COMET     = 5715,
    GOSHIKITENGE     = 5725,
    SHISAI_KABOKU    = 5881,
    MARINE_BLISS     = 5882,
    FALLING_STAR     = 5883,
    FESTIVE_FAN      = 4251,
    SUMMER_FAN       = 4252,
    SPIRIT_MASQUE    = 4253,
    RED_DROP         = 4258, -- Colored drops run 4258-4265
    BLACK_DROP       = 4265,
    PUNY_PLANET_KIT  = 3452,
    GOLDFISH_SET     = 1894,
    WHITE_BUTTERFLY  = 2770,
    BELL_CRICKET     = 2771,
    GLOWFLY          = 2772,
    IRATSUGO_HAPPI   = 25777,
    IRATSUME_HAPPI   = 25778,
}

local fireworkItems =
{
    items.GOSHIKITENGE,
    items.SHISAI_KABOKU,
    items.MARINE_BLISS,
    items.FALLING_STAR,
}

local pondInsects =
{
    items.WHITE_BUTTERFLY,
    items.BELL_CRICKET,
    items.GLOWFLY,
}

-- Points banked per goldfish traded in
local fishPoints =
{
    { items.TINY_GOLDFISH,    1  },
    { items.BLACK_BUBBLE_EYE, 2  },
    { items.LIONHEAD,         10 },
    { items.PEARLSCALE,       30 },
    { items.CALICO_COMET,     30 },
}

-- Bodies that count as festival attire for the teleport moogles
local festivalBodies =
{
    13819, -- Onoko Yukata
    13820, -- Omina Yukata
    13821, -- Lord's Yukata
    13822, -- Lady's Yukata
    14532, -- Otoko Yukata
    14533, -- Onago Yukata
    14534, -- Otokogimi Yukata
    14535, -- Onnagimi Yukata
    11316, -- Otokogusa Yukata
    11317, -- Onnagusa Yukata
    11318, -- Otokoeshi Yukata
    11319, -- Ominaeshi Yukata
    11861, -- Hikogami Yukata
    11862, -- Himegami Yukata
    27859, -- Kengyu Happi
    27860, -- Shokujo Happi
    25777, -- Iratsugo Happi
    25778, -- Iratsume Happi
}

-----------------------------------
-- Goldfish pond data
-- All message IDs verified against client DAT dialog tables (xidat)
-----------------------------------

local pondData =
{
    [xi.zone.WEST_RONFAURE] =
    {
        npcId  = 17187570, -- Saradorial (Knightswell)
        spot   = { 90, -402.5, -9.999, -436.0 },
        insect = items.WHITE_BUTTERFLY,

        npcMsg =
        {
            attract        = 7976, -- Come, my children... Enter the world of goldfish...
            buy            = 7980, -- To bond with the goldfish, one must have the right tools...
            howTo1         = 7984, -- Bonding with the goldfish is quite simple. Equip your Range slot with a <basket>...
            howTo2         = 7985, -- When you have reunited with the children of Pisces, bring them to me...
            typesIntro     = 7986, -- There are three known species of goldfish in Vana'diel...
            typeTiny       = 7987, -- <Tiny goldfish> are the most abundant in our world's waters...
            typeBlack      = 7988, -- <Black bubble-eyes> are slightly larger than most goldfish...
            typeJuicy      = 7989, -- ...if you happen to come across a <lionhead>...
            typeBonus      = 7990, -- ...innumerable mysteries abound in this vast world of ours...
            prizeIntro     = 7992, -- The universe shall reward those who have been blessed with fortune.
            prizeScoop     = 7993, -- <5> years of fortune shall bring you a new <super scoop>...
            prizeFireworks = 7994, -- <15> years of fortune shall bring you the mystical flowers of fire...
            prizeFans      = 7995, -- <25> years of fortune shall soothe your weary spirit... ornamental fan.
            prizeDrop      = 7996, -- A colored drop is carried on the sweet winds of <30> years of fortune...
            prizeMystery   = 7997, -- Those who are graced with <50> years of fortune... nirvana...
            prizeOutro     = 7998, -- Clear your mind, open your heart, and let the goldfish guide you...
            firstBasket    = 8000, -- ...I applaud you on your bravery, and present you with this <goldfish basket>.
            lostBasket1    = 8001, -- What is this, my child? Have you lost your way...
            lostBasket2    = 8002, -- ...I can provide you with another, but all the blessings... will be lost.
            replaceDecline = 8004, -- I see. I am not one to judge...
            replaceGive    = 8005, -- ...Take this new <goldfish basket> and begin once more...
            alreadyHave    = 8006, -- What is this? Are you asking me to erase your fortune...
            resetDone      = 8007, -- ...I have cleansed your soul of its fortune...
            noPoints       = 8009, -- The universe cannot provide for those who have not been graced...
            confirmAsk     = 8010, -- Are you sure this is what you wish of the universe?
            prizeAccept    = 8012, -- Excellent, my child. May you always be blessed...
            prizeDecline   = 8013, -- I understand... There is no need to rush the river of life's mystical flow.
            tradeGreet     = 8014, -- Ah, I sense great fortune approaching...
            bankLow        = 8015, -- You shall be blessed for <n> years!
            bankMid        = 8016, -- You shall be blessed for <n> years!
            bankHigh       = 8017, -- You shall be blessed for <n> years!
            pointTotal     = 8023, -- Your point total is now <n>.
        },

        actionMsg =
        {
            ripped  = 7273, -- The paper on your <super scoop> ripped.
            tiny    = 7274, -- A tiny goldfish approaches!
            black   = 7275, -- A plump, black goldfish approaches!
            juicy   = 7276, -- A fat, juicy goldfish approaches!
            none    = 7277, -- There are no goldfish to be found...
            slipped = 7279, -- The goldfish slipped off your scoop...
            hurry   = 7313, -- Hurry before the goldfish sees you!
        },

        labels =
        {
            menuTitle = 'Welcome...',
            buy       = 'I\'d like to buy a scoop.',
            explain   = 'I\'d like to know more.',
            prizeInfo = 'What one can earn.',
            bowl      = 'I\'d like a bowl.',
            collect   = 'I\'d like to collect my prize.',
            resetNo   = 'I am content with what I have.',
            resetYes  = 'I wish to regain fortunes lost.',
            sureNo    = 'My judgment remains clouded.',
            sureYes   = 'I have made up my mind.',
        },
    },

    [xi.zone.SOUTH_GUSTABERG] =
    {
        npcId  = 17216210, -- Fish Eyes (The Fumaroles)
        spot   = { 30, -441.5, 40.106, -388.2 },
        insect = items.BELL_CRICKET,

        npcMsg =
        {
            attract        = 7465, -- Hey! Get over here and play this game!
            buy            = 7469, -- Get out your <wallet, mister/purse, lady>.
            howTo1         = 7473, -- Equip a <basket> in your Range slot! Equip a <scoop> in your Ammo slot!...
            howTo2         = 7474, -- Don't think you can do your scooping just anywhere... Look for the fireworks displays.
            typesIntro     = 7475, -- Why, goldfish, of course!... There are three known kinds!...
            typeTiny       = 7476, -- <Tiny goldfish> are quick and tiny... a point for each one...
            typeBlack      = 7477, -- <Black bubble-eyes> are black and heavy. I'll give you two points...
            typeJuicy      = 7478, -- Finally, <lionheads> are big and mean... ten points for one!
            typeBonus      = 7479, -- ...there may be other kinds lurking about as well... bonus points!
            prizeIntro     = 7481, -- Why should you scoop!?... Just look at all the junk you can get...
            prizeScoop     = 7482, -- <5> points will buy you another <super scoop>...
            prizeFireworks = 7483, -- Or you can trade <15> points for a bag of fireworks...
            prizeFans      = 7484, -- Fork over <25> points and I'll give you some fans to cool off...
            prizeDrop      = 7485, -- <30> points will get you a sweet colored drop!...
            prizeMystery   = 7486, -- <50> points can be exchanged for what's in the mystery box!...
            prizeOutro     = 7487, -- Remember, you have to earn points if you want the prizes...
            firstBasket    = 7489, -- Finally come to your senses, eh!? Here's your <goldfish basket>...
            lostBasket1    = 7490, -- You lost your <goldfish basket>!?...
            lostBasket2    = 7491, -- ...I can give you another <goldfish basket>, but all the points... will be lost as well.
            replaceDecline = 7493, -- Whatever you say, champ!
            replaceGive    = 7494, -- All right, take this! And try to take better care of it this time!
            alreadyHave    = 7495, -- Wait a minute... You already have a <goldfish basket>!...
            resetDone      = 7496, -- I'll be... You really are that stupid...
            noPoints       = 7498, -- Are you trying to pull a fast one on me? Because if you are...!
            confirmAsk     = 7499, -- Are you sure that's what you really want? We offer no refunds, you know!
            prizeAccept    = nil,  -- No dedicated line in this zone; ITEM_OBTAINED covers the handover
            prizeDecline   = 7501, -- Geesh! What's got you all upset!?
            tradeGreet     = 7503, -- Well, look who's back! What do you have there!?
            bankLow        = 7504, -- That's it!? <n> points is all that you're getting.
            bankMid        = 7505, -- Not bad... Not good, but not bad. Here's <n> points for you.
            bankHigh       = 7506, -- Where did you get all these!?... Here, take <n> points.
            pointTotal     = 7512, -- Your current point total is <n>.
        },

        actionMsg =
        {
            ripped  = 7273, -- The paper on your <super scoop> ripped.
            tiny    = 7274, -- A tiny goldfish approaches!
            black   = 7275, -- A plump, black goldfish approaches!
            juicy   = 7276, -- A fat, juicy goldfish approaches!
            none    = 7277, -- There are no goldfish to be found...
            slipped = 7279, -- The goldfish slipped off your scoop...
            hurry   = 7313, -- Hurry before the goldfish sees you!
        },

        labels =
        {
            menuTitle = 'It\'s about time!',
            buy       = 'I want to buy a scoop.',
            explain   = 'What is all this scooping?',
            prizeInfo = 'What do I get for scooping?',
            bowl      = 'I need a bowl.',
            collect   = 'Collect my prize.',
            resetNo   = 'On second thought...',
            resetYes  = 'Don\'t make me answer twice!',
            sureNo    = 'I\'ve changed my mind.',
            sureYes   = 'Give me my prize!',
        },
    },

    [xi.zone.EAST_SARUTABARUTA] =
    {
        npcId  = 17253106, -- Kesha Shopehllok (Nompipi River)
        spot   = { 150, -19.6, -1.790, -48.2 },
        insect = items.GLOWFLY,

        npcMsg =
        {
            attract        = 7515, -- Step right up and test your skill at Grabbin' Goldfish!
            buy            = 7519, -- That's the spirit! Ya can't do any grabbin' without a scoop!
            howTo1         = 7523, -- ...Just equip a <basket> to your Range slot, a <scoop> to your Ammo slot...
            howTo2         = 7524, -- Oh yeah, and one last thing--ya can't grab goldfish just anywhere...
            typesIntro     = 7525, -- There are three types of goldfish...
            typeTiny       = 7526, -- <Tiny goldfish> are probably the easiest to grab... one point...
            typeBlack      = 7527, -- <Black bubble-eyes> are a li'l bit bigger... two points...
            typeJuicy      = 7528, -- And <lionheads>?... a whoppin' ten points!
            typeBonus      = 7529, -- But wait, there's more!... worth your while!
            prizeIntro     = 7531, -- Ya bring me goldfish, I'll give ya points... Simple, huh?
            prizeScoop     = 7532, -- <5> points'll get ya a new <super scoop>.
            prizeFireworks = 7533, -- <15> points'll get ya a bag o' fireworks...
            prizeFans      = 7534, -- <25> points'll get ya some fan-dangled fans...
            prizeDrop      = 7535, -- <30> points'll get ya a delicious drop...
            prizeMystery   = 7536, -- <50> points'll get ya...well, I can't give ya any details...
            prizeOutro     = 7537, -- And that's the lowdown on our prizes.
            firstBasket    = 7539, -- Alright! Here's a <goldfish basket> to put your goldfish in...
            lostBasket1    = 7540, -- Ya lost your <goldfish basket>!?
            lostBasket2    = 7541, -- ...I have no problem with lendin' ya another one, but... ya lose all the points...
            replaceDecline = 7543, -- Oh well. If ya change your mind, ya know where I'll be!
            replaceGive    = 7544, -- Well, okay! Take this new <goldfish basket>... your points are reset to zero.
            alreadyHave    = 7545, -- Wait a minute... You already have a <goldfish basket>...
            resetDone      = 7546, -- Whatever. Ya know, if I only had more customers like you...
            noPoints       = 7548, -- Hey, you're gonna need to do some more grabbin' if ya want that.
            confirmAsk     = 7549, -- Are ya sure that's what ya want?
            prizeAccept    = 7551, -- Then here ya go!
            prizeDecline   = 7552, -- Oh. Well, come back when you've made up your mind.
            tradeGreet     = 7553, -- <Sniff> <Sniff> Is that goldfish I smell?
            bankLow        = 7554, -- Let's see... I'll give ya <n> points for this haul.
            bankMid        = 7555, -- Wow... I'll give ya <n> points for all of these.
            bankHigh       = 7556, -- With all these fish, you could open your own pet shop!... <n> points.
            pointTotal     = 7562, -- Your point total is now <n>.
        },

        actionMsg =
        {
            ripped  = 7251, -- The paper on your <super scoop> ripped.
            tiny    = 7252, -- A tiny goldfish approaches!
            black   = 7253, -- A plump, black goldfish approaches!
            juicy   = 7254, -- A fat, juicy goldfish approaches!
            none    = 7255, -- There are no goldfish to be found...
            slipped = 7257, -- The goldfish slipped off your scoop...
            hurry   = 7291, -- Hurry before the goldfish sees you!
        },

        labels =
        {
            menuTitle = 'What can I do ya for?',
            buy       = 'Get me a scoop.',
            explain   = 'How does this game work?',
            prizeInfo = 'About the prizes.',
            bowl      = 'I need a bowl.',
            collect   = 'Fork over my prize.',
            resetNo   = 'No way!',
            resetYes  = 'You bet!',
            sureNo    = 'Hold on.',
            sureYes   = 'You bet.',
        },
    },

    [xi.zone.RABAO] =
    {
        npcId  = 17789025, -- Mei (Rabao spring)
        spot   = { 200, -34.6, 7.999, 57.0 },
        insect = nil, -- Mei hands out a random insect

        npcMsg =
        {
            attract        = 10413, -- Goldfish... Goldfish...something...
            buy            = 10417, -- Whatever...
            howTo1         = 10421, -- <Goldfish basket> in your Range slot... <Super scoop> in your Ammo slot...
            howTo2         = 10422, -- Goldfish only found in areas with...fireworks displays...or whatever...
            typesIntro     = 10423, -- Three...or so types: <tiny goldfish>, <black bubble-eyes>, and <lionheads>...
            typeTiny       = 10424, -- <Tiny goldfish>...tiny, red...easy to catch...probably...
            typeBlack      = 10425, -- <Black bubble-eyes>...fat...ugly...like me... Two points...or so...
            typeJuicy      = 10426, -- <Lionheads>...big... Break your...scoop thingy... Maybe...ten points...
            typeBonus      = 10427, -- There are...other types...maybe... Catch them...for bonus points...
            prizeIntro     = 10429, -- Six...or so types of prizes... Use your points...or whatever...
            prizeScoop     = 10430, -- <5> points gets you a new <super scoop>... Whoopee...
            prizeFireworks = 10431, -- <15> points for...bag of something... fireworks, maybe...
            prizeFans      = 10433, -- Fan thingies...cool down for...<25> points...
            prizeDrop      = 10432, -- <30> points buys...assorted drop... I think...
            prizeMystery   = 10434, -- <50> points gets you...whatever's in the mystery box...
            prizeOutro     = 10435, -- Buy scoops... Scoop fish... Get points... Win cheap prizes...
            firstBasket    = 10437, -- Huh...? Oh...here... Take this <goldfish basket>... Don't lose it...
            lostBasket1    = 10438, -- Lost your <goldfish basket>...? Whatever...
            lostBasket2    = 10439, -- You can have a new one... You'll lose your points...like I care...
            replaceDecline = 10441, -- Yeah...okay...
            replaceGive    = 10442, -- It's your life... Here's your new <goldfish basket>...
            alreadyHave    = 10443, -- Can't give you another...bowl thing...unless you want your points reset to zero...
            resetDone      = 10444, -- Zero points it is...
            noPoints       = 10446, -- Ummm... Need more points...or something...
            confirmAsk     = 10447, -- Are you sure...and everything...?
            prizeAccept    = 10449, -- Here... Are you done...?
            prizeDecline   = 10450, -- Okay... Are you done...?
            tradeGreet     = 10451, -- Oh boy... Counting goldfish...
            bankLow        = 10452, -- Hm... I don't know...<n> points...?
            bankMid        = 10453, -- Hmmm... <n> points...maybe?
            bankHigh       = 10454, -- <Sigh> It's going to take me forever to count all these... <n> points...or so...
            pointTotal     = 10458, -- <Player>'s point total is now <n>.
        },

        actionMsg =
        {
            ripped  = 6701, -- The paper on your <super scoop> ripped.
            tiny    = 6702, -- A tiny goldfish approaches!
            black   = 6703, -- A plump, black goldfish approaches!
            juicy   = 6704, -- A fat, juicy goldfish approaches!
            none    = 6705, -- There are no goldfish to be found...
            slipped = 6707, -- The goldfish slipped off your scoop...
            hurry   = 6741, -- Hurry before the goldfish sees you!
        },

        labels =
        {
            menuTitle = 'Yeah...?',
            buy       = 'I want to buy a scoop.',
            explain   = 'Tell me how to play.',
            prizeInfo = 'About the prizes.',
            bowl      = 'I\'d like a bowl.',
            collect   = 'I\'m ready for my prize.',
            resetNo   = 'I\'m...not sure...',
            resetYes  = 'Whatever...hand it over...',
            sureNo    = 'Just...forget it...',
            sureYes   = 'Get me my stuff...or whatever...',
        },
    },
}

-----------------------------------
-- City moogle data
-----------------------------------

-- Festival plaza greeters (same spots as the other seasonal moogles)
local greeterData =
{
    [xi.zone.SOUTHERN_SAN_DORIA] = { pos = { 194, 56.195, 1.999, -25.207 },    greet = 10410 },
    [xi.zone.NORTHERN_SAN_DORIA] = { pos = { 128, -224.135, 8.000, 53.476 },   greet = 14353 },
    [xi.zone.BASTOK_MINES]       = { pos = { 0, -33.600, -0.001, -110.000 },   greet = 12577 },
    [xi.zone.BASTOK_MARKETS]     = { pos = { 40, -260.440, -12.021, -79.538 }, greet = 9237  },
    [xi.zone.WINDURST_WATERS]    = { pos = { 0, -55.470, -5.391, 216.362 },    greet = 12029 },
    [xi.zone.WINDURST_WOODS]     = { pos = { 161, 104.823, -5.000, -55.745 },  greet = 10278 },
}

-- Item stall moogles
local stallData =
{
    [xi.zone.NORTHERN_SAN_DORIA] = { pos = { 0, -245.000, 8.000, 44.000 } },
    [xi.zone.BASTOK_MINES]       = { pos = { 127, 80.500, 0.000, -72.000 } },
    [xi.zone.WINDURST_WATERS]    = { pos = { 63, -44.000, -4.900, 226.200 } },
}

-- Teleportation moogles
local nations =
{
    SANDORIA = 1,
    BASTOK   = 2,
    WINDURST = 3,
}

local teleportArrivals =
{
    [nations.SANDORIA] = { x = 54.5, y = 1.999, z = -20.5, rot = 96, zone = xi.zone.SOUTHERN_SAN_DORIA },
    [nations.BASTOK]   = { x = -88.5, y = -2.0, z = 6.5, rot = 128, zone = xi.zone.PORT_BASTOK },
    [nations.WINDURST] = { x = 102.5, y = -5.0, z = -51.0, rot = 192, zone = xi.zone.WINDURST_WOODS },
}

local teleporterData =
{
    [xi.zone.SOUTHERN_SAN_DORIA] =
    {
        pos          = { 194, 53.0, 1.999, -22.0 },
        accept1      = 13517, -- Looks like you've really gotten into the spirit of the Sunbreeze Festival, kupo!
        accept2      = 13518, -- As a show of appreciation, I'll teleport you to one of the other nations!...
        sendoff      = 13515, -- Enjoy your trip, kupo!
        decline      = 9912,  -- You're not wearing your yukata! Put it on and show me how it looks, kupo!
        destinations = { nations.BASTOK, nations.WINDURST },
    },

    [xi.zone.PORT_BASTOK] =
    {
        pos          = { 64, -90.0, -2.0, 5.0 },
        accept1      = 12855, -- Looks like you've really gotten into the spirit of the Sunbreeze Festival, kupo!
        accept2      = 12856, -- As a show of appreciation, I'll teleport you to one of the other nations!...
        sendoff      = 12853, -- Enjoy your trip, kupo!
        decline      = nil,   -- No yukata-gate line in this zone's dialog table
        destinations = { nations.SANDORIA, nations.WINDURST },
    },

    [xi.zone.WINDURST_WOODS] =
    {
        pos          = { 161, 101.0, -5.0, -52.5 },
        accept1      = 13334, -- Looks like you've really gotten into the spirit of the Sunbreeze Festival, kupo!
        accept2      = 13335, -- As a show of appreciation, I'll teleport you to one of the other nations!...
        sendoff      = 13332, -- Enjoy your trip, kupo!
        decline      = 9847,  -- You're not wearing your yukata! Put it on and show me how it looks, kupo!
        destinations = { nations.SANDORIA, nations.BASTOK },
    },
}

local nationLabels =
{
    [nations.SANDORIA] = 'San d\'Oria.',
    [nations.BASTOK]   = 'Bastok.',
    [nations.WINDURST] = 'Windurst.',
}

-----------------------------------
-- Helpers
-----------------------------------

-- New menus sent from within a menu callback need a tiny delay
-- so the previous menu context is cleared out first
local delayMenu = function(player, menu)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

local getPoints = function(player)
    return player:getCharVar(settings.VAR.SCOOP_POINTS)
end

local setPoints = function(player, value)
    player:setCharVar(settings.VAR.SCOOP_POINTS, value)
end

local rollFireworkBag = function()
    local counts = {}

    for i = 1, math.random(3, 5) do
        local fireworkId = fireworkItems[math.random(1, #fireworkItems)]
        counts[fireworkId] = (counts[fireworkId] or 0) + 1
    end

    local bag = {}

    for fireworkId, qty in pairs(counts) do
        table.insert(bag, { fireworkId, qty })
    end

    return bag
end

local isWearing = function(player, itemList)
    local body = player:getEquipID(xi.slot.BODY)

    for _, itemId in pairs(itemList) do
        if body == itemId then
            return true
        end
    end

    return false
end

-----------------------------------
-- Goldfish pond NPC handlers
-----------------------------------

local buyScoop = function(player, data)
    if player:getGil() < settings.SCOOP_PRICE then
        player:printToPlayer('You do not have enough gil.', xi.msg.channel.NS_SAY)
        return
    end

    player:messageSpecial(data.npcMsg.buy)

    if npcUtil.giveItem(player, items.SUPER_SCOOP) then
        player:delGil(settings.SCOOP_PRICE)
    end
end

local explainScooping = function(player, data)
    player:messageSpecial(data.npcMsg.howTo1, items.GOLDFISH_BASKET, items.SUPER_SCOOP)
    player:messageSpecial(data.npcMsg.howTo2)
    player:messageSpecial(data.npcMsg.typesIntro, items.TINY_GOLDFISH, items.BLACK_BUBBLE_EYE, items.LIONHEAD)
    player:messageSpecial(data.npcMsg.typeTiny, items.TINY_GOLDFISH, items.BLACK_BUBBLE_EYE, items.LIONHEAD)
    player:messageSpecial(data.npcMsg.typeBlack, items.TINY_GOLDFISH, items.BLACK_BUBBLE_EYE, items.LIONHEAD)
    player:messageSpecial(data.npcMsg.typeJuicy, items.TINY_GOLDFISH, items.BLACK_BUBBLE_EYE, items.LIONHEAD)
    player:messageSpecial(data.npcMsg.typeBonus)
end

local explainPrizes = function(player, data)
    player:messageSpecial(data.npcMsg.prizeIntro)
    player:messageSpecial(data.npcMsg.prizeScoop, 5, items.SUPER_SCOOP)
    player:messageSpecial(data.npcMsg.prizeFireworks, 15)
    player:messageSpecial(data.npcMsg.prizeFans, 25)
    player:messageSpecial(data.npcMsg.prizeDrop, 30)
    player:messageSpecial(data.npcMsg.prizeMystery, 50)
    player:messageSpecial(data.npcMsg.prizeOutro)
end

local bowlMenu = function(player, data)
    local msg = data.npcMsg

    -- Already has a basket: offer a point reset, retail style
    if player:hasItem(items.GOLDFISH_BASKET) then
        player:messageSpecial(msg.alreadyHave, items.GOLDFISH_BASKET)

        delayMenu(player,
        {
            title   = 'Start over from the top?',
            options =
            {
                {
                    data.labels.resetNo,
                    function(playerArg)
                        playerArg:messageSpecial(msg.replaceDecline)
                    end,
                },
                {
                    data.labels.resetYes,
                    function(playerArg)
                        setPoints(playerArg, 0)
                        playerArg:messageSpecial(msg.resetDone)
                    end,
                },
            },
        })

        return
    end

    -- First basket is free
    if player:getCharVar(settings.VAR.HAS_BASKET) == 0 then
        player:messageSpecial(msg.firstBasket, items.GOLDFISH_BASKET)

        if npcUtil.giveItem(player, items.GOLDFISH_BASKET) then
            player:setCharVar(settings.VAR.HAS_BASKET, 1)
        end

        return
    end

    -- Lost the basket: replacement resets banked points to zero
    player:messageSpecial(msg.lostBasket1, items.GOLDFISH_BASKET)
    player:messageSpecial(msg.lostBasket2, items.GOLDFISH_BASKET)

    delayMenu(player,
    {
        title   = 'Start over from the top?',
        options =
        {
            {
                data.labels.resetNo,
                function(playerArg)
                    playerArg:messageSpecial(msg.replaceDecline)
                end,
            },
            {
                data.labels.resetYes,
                function(playerArg)
                    if npcUtil.giveItem(playerArg, items.GOLDFISH_BASKET) then
                        setPoints(playerArg, 0)
                        playerArg:messageSpecial(msg.replaceGive, items.GOLDFISH_BASKET)
                    end
                end,
            },
        },
    })
end

local rollPrize = function(player, data, prizeType)
    if prizeType == 1 then
        return { { items.SUPER_SCOOP, 1 } }
    elseif prizeType == 2 then
        return rollFireworkBag()
    elseif prizeType == 3 then
        local fans = { items.FESTIVE_FAN, items.SUMMER_FAN }
        return { { fans[math.random(1, #fans)], 2 } }
    elseif prizeType == 4 then
        return { { math.random(items.RED_DROP, items.BLACK_DROP), 1 } }
    elseif prizeType == 5 then
        return { { items.SPIRIT_MASQUE, 12 } }
    elseif prizeType == 6 then
        return { { items.PUNY_PLANET_KIT, 1 } }
    elseif prizeType == 7 then
        return { { items.GOLDFISH_SET, 1 } }
    elseif prizeType == 8 then
        local insect = data.insect

        if not insect then
            insect = pondInsects[math.random(1, #pondInsects)]
        end

        return { { insect, math.random(1, 5) } }
    elseif prizeType == 9 then
        -- getGender returns 0 for female, 1 for male
        if player:getGender() == 1 then
            return { { items.IRATSUGO_HAPPI, 1 } }
        else
            return { { items.IRATSUME_HAPPI, 1 } }
        end
    end

    return nil
end

local selectPrize = function(player, data, cost, prizeType)
    local msg = data.npcMsg

    if getPoints(player) < cost then
        player:messageSpecial(msg.noPoints)
        return
    end

    player:messageSpecial(msg.confirmAsk)

    delayMenu(player,
    {
        title   = 'What to do...',
        options =
        {
            {
                data.labels.sureNo,
                function(playerArg)
                    playerArg:messageSpecial(msg.prizeDecline)
                end,
            },
            {
                data.labels.sureYes,
                function(playerArg)
                    local reward = rollPrize(playerArg, data, prizeType)

                    if reward and npcUtil.giveItem(playerArg, reward) then
                        local newTotal = getPoints(playerArg) - cost
                        setPoints(playerArg, newTotal)

                        if msg.prizeAccept then
                            playerArg:messageSpecial(msg.prizeAccept)
                        end

                        playerArg:messageSpecial(msg.pointTotal, newTotal)
                    end
                end,
            },
        },
    })
end

local collectPrizeMenu = function(player, data)
    local prizeRows =
    {
        { 'A super scoop: 5 points.',          5,  1 },
        { 'A bag of fireworks: 15 points.',    15, 2 },
        { 'Large fans: 25 points.',            25, 3 },
        { 'A colored drop: 30 points.',        30, 4 },
        { 'The mystery box: 50 points.',       50, 5 },
        { 'A stellar surprise: 60 points.',    60, 6 },
        { 'The other mystery box: 65 points.', 65, 7 },
        { 'Yet another mystery box: 70 points.', 70, 8 },
        { 'Mystery box part four: 80 points.', 80, 9 },
    }

    local options = {}

    for _, row in ipairs(prizeRows) do
        table.insert(options,
        {
            row[1],
            function(playerArg)
                selectPrize(playerArg, data, row[2], row[3])
            end,
        })
    end

    table.insert(options,
    {
        'Nothing.',
        function(playerArg)
            playerArg:messageSpecial(data.npcMsg.prizeDecline)
        end,
    })

    delayMenu(player,
    {
        title   = string.format('You have %u points.', getPoints(player)),
        options = options,
    })
end

xi.events.sunbreeze.onPondTrigger = function(player, npc)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    local data = pondData[player:getZoneID()]
    if not data then
        return
    end

    npc:facePlayer(player, true)
    player:messageText(npc, data.npcMsg.attract)

    player:customMenu({
        title   = data.labels.menuTitle,
        options =
        {
            {
                data.labels.buy,
                function(playerArg)
                    buyScoop(playerArg, data)
                end,
            },
            {
                data.labels.explain,
                function(playerArg)
                    explainScooping(playerArg, data)
                end,
            },
            {
                data.labels.prizeInfo,
                function(playerArg)
                    explainPrizes(playerArg, data)
                end,
            },
            {
                data.labels.bowl,
                function(playerArg)
                    bowlMenu(playerArg, data)
                end,
            },
            {
                data.labels.collect,
                function(playerArg)
                    collectPrizeMenu(playerArg, data)
                end,
            },
        },
    })
end

xi.events.sunbreeze.onPondTrade = function(player, npc, trade)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    local data = pondData[player:getZoneID()]
    if not data then
        return
    end

    -- Every traded item must be a goldfish
    local earned = 0

    for slot = 0, trade:getSlotCount() - 1 do
        local slotItem = trade:getItemId(slot)
        local slotQty  = trade:getSlotQty(slot)
        local slotWorth = 0

        for _, fish in pairs(fishPoints) do
            if fish[1] == slotItem then
                slotWorth = fish[2]
            end
        end

        if slotWorth == 0 then
            return
        end

        earned = earned + slotWorth * slotQty
    end

    if earned == 0 then
        return
    end

    npc:facePlayer(player, true)
    player:messageText(npc, data.npcMsg.tradeGreet)

    if earned < 10 then
        player:messageSpecial(data.npcMsg.bankLow, earned)
    elseif earned < 30 then
        player:messageSpecial(data.npcMsg.bankMid, earned)
    else
        player:messageSpecial(data.npcMsg.bankHigh, earned)
    end

    local newTotal = getPoints(player) + earned
    setPoints(player, newTotal)
    player:confirmTrade()
    player:messageSpecial(data.npcMsg.pointTotal, newTotal)
end

-----------------------------------
-- Scooping spot (timing minigame)
-----------------------------------

-- Scooping state (player local vars):
-- sunbreezeScoopState: 0 = idle, 1 = waiting for a goldfish, 2 = catch window running
-- sunbreezeScoopFish : 1 = tiny, 2 = black, 3 = juicy
-- sunbreezeScoopTime : GetSystemTime() timestamps

local beginScoopAttempt = function(player, data)
    player:setLocalVar('sunbreezeScoopState', 1)
    player:setLocalVar('sunbreezeScoopTime', GetSystemTime())

    local zoneId = player:getZoneID()

    player:timer(math.random(2000, 8000), function(playerArg)
        if
            playerArg:getLocalVar('sunbreezeScoopState') ~= 1 or
            playerArg:getZoneID() ~= zoneId
        then
            return
        end

        -- Weighted approach roll, shifted by a Lord's/Lady's Yukata
        local body = playerArg:getEquipID(xi.slot.BODY)
        local weights = { 45, 25, 15 } -- tiny, black, juicy (remainder: none)

        if
            body == 13821 or -- Lord's Yukata
            body == 13822    -- Lady's Yukata
        then
            weights = { 30, 30, 25 }
        end

        local roll = math.random(1, 100)

        if roll <= weights[1] then
            playerArg:messageSpecial(data.actionMsg.tiny)
            playerArg:setLocalVar('sunbreezeScoopFish', 1)
        elseif roll <= weights[1] + weights[2] then
            playerArg:messageSpecial(data.actionMsg.black)
            playerArg:setLocalVar('sunbreezeScoopFish', 2)
        elseif roll <= weights[1] + weights[2] + weights[3] then
            playerArg:messageSpecial(data.actionMsg.juicy)
            playerArg:setLocalVar('sunbreezeScoopFish', 3)
        else
            playerArg:messageSpecial(data.actionMsg.none)
            playerArg:setLocalVar('sunbreezeScoopState', 0)
            return
        end

        playerArg:timer(2000, function(playerArg2)
            if
                playerArg2:getLocalVar('sunbreezeScoopState') ~= 1 or
                playerArg2:getZoneID() ~= zoneId
            then
                return
            end

            playerArg2:messageSpecial(data.actionMsg.hurry)
            playerArg2:setLocalVar('sunbreezeScoopTime', GetSystemTime())
            playerArg2:setLocalVar('sunbreezeScoopState', 2)
        end)
    end)
end

local resolveScoop = function(player, data)
    local elapsed = GetSystemTime() - player:getLocalVar('sunbreezeScoopTime')
    player:setLocalVar('sunbreezeScoopState', 0)

    -- Stale attempt (walked away mid-minigame): quietly start over
    if elapsed > 30 then
        beginScoopAttempt(player, data)
        return
    end

    -- Too early: the goldfish gets away, scoop survives
    if elapsed < 1 then
        player:messageSpecial(data.actionMsg.slipped)
        return
    end

    -- Too late: the paper rips
    if elapsed > 4 then
        player:messageSpecial(data.actionMsg.ripped, items.SUPER_SCOOP)
        player:delItem(items.SUPER_SCOOP, 1)
        return
    end

    -- Caught one!
    local fishType = player:getLocalVar('sunbreezeScoopFish')
    local body = player:getEquipID(xi.slot.BODY)
    local reward = nil

    if
        fishType == 1 or
        fishType == 2
    then
        local qty = 1

        if
            body == 11318 or -- Otokoeshi Yukata
            body == 11319    -- Ominaeshi Yukata
        then
            qty = math.random(1, 3)
        end

        if fishType == 1 then
            reward = { { items.TINY_GOLDFISH, qty } }
        else
            reward = { { items.BLACK_BUBBLE_EYE, qty } }
        end
    else
        local roll = math.random(1, 100)

        if roll <= 60 then
            reward = { { items.LIONHEAD, 1 } }
        elseif roll <= 80 then
            reward = { { items.PEARLSCALE, 1 } }
        else
            reward = { { items.CALICO_COMET, 1 } }
        end
    end

    if npcUtil.giveItem(player, reward) then
        player:delItem(items.SUPER_SCOOP, 1)
    end
end

xi.events.sunbreeze.onSpotTrigger = function(player, npc)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    local data = pondData[player:getZoneID()]
    if not data then
        return
    end

    if player:getEquipID(xi.slot.RANGED) ~= items.GOLDFISH_BASKET then
        player:printToPlayer('You need a goldfish basket equipped in your range slot to go scooping.', xi.msg.channel.NS_SAY)
        return
    end

    if not player:hasItem(items.SUPER_SCOOP) then
        player:printToPlayer('You do not have any super scoops.', xi.msg.channel.NS_SAY)
        return
    end

    local state = player:getLocalVar('sunbreezeScoopState')

    if state == 0 then
        beginScoopAttempt(player, data)
    elseif state == 2 then
        resolveScoop(player, data)
    end

    -- state 1: a goldfish is still on its way, wait quietly
end

-----------------------------------
-- Festival greeter moogles
-----------------------------------

local greeterHint = 'The goldfish ponds are open at Knightswell in West Ronfaure, ' ..
    'the Fumaroles in South Gustaberg, the Nompipi River in East Sarutabaruta, and the spring in Rabao. ' ..
    'Yukata and fireworks are on sale at our festival stalls, kupo!'

xi.events.sunbreeze.onGreeterTrigger = function(player, npc)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    local data = greeterData[player:getZoneID()]
    if not data then
        return
    end

    npc:facePlayer(player, true)
    player:messageText(npc, data.greet)
    player:printToPlayer(greeterHint, xi.msg.channel.NS_SAY, 'Festival Moogle')

    -- Daily festival firework handout
    if player:getCharVar(settings.VAR.DAILY_GIFT) < VanadielUniqueDay() then
        local firework = fireworkItems[math.random(1, #fireworkItems)]

        if npcUtil.giveItem(player, firework) then
            player:setCharVar(settings.VAR.DAILY_GIFT, VanadielUniqueDay())
        end
    end
end

-----------------------------------
-- Item stall moogles
-----------------------------------

-- Retail back-catalog prices
local stallStock =
{
    { menu = 'Yukata (2,500-5,000 gil)', wares =
        {
            { 'Onoko Yukata (2,500 gil)',  13819, 2500 },
            { 'Omina Yukata (2,500 gil)',  13820, 2500 },
            { 'Lord\'s Yukata (3,750 gil)', 13821, 3750 },
            { 'Lady\'s Yukata (3,750 gil)', 13822, 3750 },
            { 'Otoko Yukata (5,000 gil)',  14532, 5000 },
            { 'Onago Yukata (5,000 gil)',  14533, 5000 },
        },
    },
    { menu = 'Yukata (7,500-15,000 gil)', wares =
        {
            { 'Otokogimi Yukata (7,500 gil)',   14534, 7500 },
            { 'Onnagimi Yukata (7,500 gil)',    14535, 7500 },
            { 'Otokogusa Yukata (10,000 gil)',  11316, 10000 },
            { 'Onnagusa Yukata (10,000 gil)',   11317, 10000 },
            { 'Otokoeshi Yukata (12,500 gil)',  11318, 12500 },
            { 'Ominaeshi Yukata (12,500 gil)',  11319, 12500 },
            { 'Hikogami Yukata (15,000 gil)',   11861, 15000 },
            { 'Himegami Yukata (15,000 gil)',   11862, 15000 },
        },
    },
    { menu = 'Happi and hanmomohiki (15,000 gil)', wares =
        {
            { 'Kengyu Happi (15,000 gil)',        27859, 15000 },
            { 'Shokujo Happi (15,000 gil)',       27860, 15000 },
            { 'Kengyu Hanmomohiki (15,000 gil)',  28149, 15000 },
            { 'Shokujo Hanmomohiki (15,000 gil)', 28150, 15000 },
        },
    },
    { menu = 'Fans (8 gil)', wares =
        {
            { 'Summer Fan (8 gil)',  4252, 8 },
            { 'Festive Fan (8 gil)', 4251, 8 },
        },
    },
    { menu = 'Fireworks (125 gil)', wares =
        {
            { 'Falling Star (125 gil)',  5883, 125 },
            { 'Shisai Kaboku (125 gil)', 5881, 125 },
            { 'Marine Bliss (125 gil)',  5882, 125 },
            { 'Goshikitenge (125 gil)',  5725, 125 },
        },
    },
    { menu = 'Bells (10,000 gil)', wares =
        {
            { 'Carillon Vermeil (10,000 gil)', 3643, 10000 },
            { 'Aeolsglocke (10,000 gil)',      3644, 10000 },
            { 'Leafbell (10,000 gil)',         3645, 10000 },
        },
    },
}

local buyStallItem = function(player, itemId, price)
    if player:getGil() < price then
        player:printToPlayer('You do not have enough gil, kupo!', xi.msg.channel.NS_SAY, 'Festival Moogle')
        return
    end

    if npcUtil.giveItem(player, itemId) then
        player:delGil(price)
    end
end

local stallMainMenu

local stallCategoryMenu = function(player, category)
    local options = {}

    for _, ware in ipairs(category.wares) do
        table.insert(options,
        {
            ware[1],
            function(playerArg)
                buyStallItem(playerArg, ware[2], ware[3])
            end,
        })
    end

    table.insert(options,
    {
        'Back.',
        function(playerArg)
            stallMainMenu(playerArg)
        end,
    })

    delayMenu(player,
    {
        title   = category.menu,
        options = options,
    })
end

stallMainMenu = function(player)
    local options = {}

    for _, category in ipairs(stallStock) do
        table.insert(options,
        {
            category.menu,
            function(playerArg)
                stallCategoryMenu(playerArg, category)
            end,
        })
    end

    delayMenu(player,
    {
        title   = 'Sunbreeze Festival goods, kupo!',
        options = options,
    })
end

xi.events.sunbreeze.onStallTrigger = function(player, npc)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    npc:facePlayer(player, true)
    stallMainMenu(player)
end

-----------------------------------
-- Teleportation moogles
-----------------------------------

xi.events.sunbreeze.onTeleporterTrigger = function(player, npc)
    if not xi.events.sunbreeze.enabledCheck() then
        return
    end

    local data = teleporterData[player:getZoneID()]
    if not data then
        return
    end

    npc:facePlayer(player, true)

    if not isWearing(player, festivalBodies) then
        if data.decline then
            player:messageText(npc, data.decline)
        else
            player:printToPlayer('You\'re not wearing your yukata! Put it on and show me how it looks, kupo!', xi.msg.channel.NS_SAY, 'Festival Moogle')
        end

        return
    end

    player:messageText(npc, data.accept1)
    player:messageText(npc, data.accept2)

    local options = {}

    for _, destination in ipairs(data.destinations) do
        table.insert(options,
        {
            nationLabels[destination],
            function(playerArg)
                local arrival = teleportArrivals[destination]
                playerArg:messageText(npc, data.sendoff)
                playerArg:timer(500, function(playerArg2)
                    playerArg2:setPos(arrival.x, arrival.y, arrival.z, arrival.rot, arrival.zone)
                end)
            end,
        })
    end

    table.insert(options,
    {
        'Nowhere.',
        function(playerArg)
        end,
    })

    player:customMenu({
        title   = 'Where will you go?',
        options = options,
    })
end

-----------------------------------
-- Show/hide entities
-----------------------------------

local function insertMoogle(zone, pos, triggerFunc)
    local npc = zone:insertDynamicEntity({
        objtype              = xi.objType.NPC,
        name                 = 'Sunbreeze_Moogle',
        packetName           = 'Festival Moogle',
        look                 = 82,
        x                    = pos[2],
        y                    = pos[3],
        z                    = pos[4],
        rotation             = pos[1],
        onTrigger            = triggerFunc,
        releaseIdOnDisappear = true,
    })

    table.insert(xi.events.sunbreeze.entities, npc:getID())
end

local function insertGreeterMoogle(zone, pos)
    local npc = zone:insertDynamicEntity({
        objtype              = xi.objType.NPC,
        name                 = 'Sunbreeze_Moogle',
        packetName           = 'Festival Moogle',
        look                 = 82,
        x                    = pos[2],
        y                    = pos[3],
        z                    = pos[4],
        rotation             = pos[1],
        onTrigger            = xi.events.sunbreeze.onGreeterTrigger,
        releaseIdOnDisappear = true,
    })

    table.insert(xi.events.sunbreeze.entities, npc:getID())
end

local function insertScoopingSpot(zone, pos)
    local npc = zone:insertDynamicEntity({
        objtype              = xi.objType.NPC,
        name                 = 'Scooping_Spot',
        packetName           = 'Scooping Spot',
        look                 = '0x00006B0500000000000000000000000000000000',
        x                    = pos[2],
        y                    = pos[3],
        z                    = pos[4],
        rotation             = pos[1],
        onTrigger            = xi.events.sunbreeze.onSpotTrigger,
        releaseIdOnDisappear = true,
    })

    table.insert(xi.events.sunbreeze.entities, npc:getID())
end

xi.events.sunbreeze.generateEntities = function()
    for zoneId, data in pairs(greeterData) do
        local zone = GetZone(zoneId)
        if zone then
            insertGreeterMoogle(zone, data.pos)
        end
    end

    for zoneId, data in pairs(stallData) do
        local zone = GetZone(zoneId)
        if zone then
            insertMoogle(zone, data.pos, xi.events.sunbreeze.onStallTrigger)
        end
    end

    for zoneId, data in pairs(teleporterData) do
        local zone = GetZone(zoneId)
        if zone then
            insertMoogle(zone, data.pos, xi.events.sunbreeze.onTeleporterTrigger)
        end
    end

    for zoneId, data in pairs(pondData) do
        local zone = GetZone(zoneId)
        if zone then
            insertScoopingSpot(zone, data.spot)
        end
    end
end

xi.events.sunbreeze.showEntities = function(enabled)
    if
        enabled and
        #xi.events.sunbreeze.entities == 0
    then
        xi.events.sunbreeze.generateEntities()
    end

    for _, entityID in pairs(xi.events.sunbreeze.entities) do
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
        xi.events.sunbreeze.entities = {}
    end
end

xi.events.sunbreeze.showPondNpcs = function(enabled)
    for zoneId, data in pairs(pondData) do
        local zone = GetZone(zoneId)
        if zone then
            local pondNpc = GetNPCByID(data.npcId)
            if pondNpc then
                if enabled then
                    pondNpc:setStatus(xi.status.NORMAL)
                else
                    pondNpc:setStatus(xi.status.DISAPPEAR)
                end
            end
        end
    end
end

event:setStartFunction(function()
    xi.events.sunbreeze.showEntities(true)
    xi.events.sunbreeze.showPondNpcs(true)
end)

event:setEndFunction(function()
    xi.events.sunbreeze.showEntities(false)
    xi.events.sunbreeze.showPondNpcs(false)
end)

return event
