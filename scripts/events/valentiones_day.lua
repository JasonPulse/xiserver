-----------------------------------
-- Valentione's Day
-----------------------------------
-- Classic matchmaking event (2005-2012 era, still-current mechanic).
-- Event Moogle positions (shared with the Egg Hunt moogles):
-- Southern San d'Oria !pos 56.195 1.999 -25.207 230
-- Northern San d'Oria !pos -224.135 8.000 53.476 231
-- Bastok Mines        !pos -33.600 -0.001 -110.000 234
-- Bastok Markets      !pos -260.440 -12.021 -79.538 235
-- Windurst Waters     !pos -55.470 -5.391 216.362 238
-- Windurst Woods      !pos 104.823 -5.000 -55.745 241
-----------------------------------
-- Flow: talk to a moogle to start a round (one per game day). The four
-- singles of the player's own sex in that city pair each hand out the
-- left + right halves of their racial chocolate and state the type of
-- partner they are looking for. Right halves are meant to be swapped
-- with players of the opposite sex. Trade a left half plus an
-- opposite-sex right half to a moogle to receive a whole chocolate,
-- then return it to the single who gave out that left half. Once all
-- four singles have their chocolate, the moogle scores the round and
-- offers a reward.
-----------------------------------
xi = xi or {}
xi.events = xi.events or {}
xi.events.valentione = xi.events.valentione or {}
xi.events.valentione.entities = xi.events.valentione.entities or {}

local event = SeasonalEvent:new('valentiones_day')

-- Default settings
local settings =
{
    ANNOUNCE = false, -- Announce settings on load
    START  = { DAY =  1, MONTH = 2 },
    FINISH = { DAY = 15, MONTH = 2 },

    VAR =
    {
        DAILY       = '[VALENTIONE]DAILY',       -- VanadielUniqueDay of the last round start
        ROUND       = '[VALENTIONE]ROUND',       -- 0 = no round, otherwise nation + 1
        PERS_M      = '[VALENTIONE]PERS_M',      -- 4 male singles' personalities, packed base 4 by race index
        PERS_F      = '[VALENTIONE]PERS_F',      -- 4 female singles' personalities, packed base 4 by race index
        DESIRE      = '[VALENTIONE]DESIRE',      -- same-sex singles' desired race + personality, packed base 16
        HANDOUT     = '[VALENTIONE]HANDOUT',     -- bitmask of singles that handed out their halves
        RETURNED    = '[VALENTIONE]RETURNED',    -- bitmask of singles that got their whole chocolate back
        SCORE       = '[VALENTIONE]SCORE',       -- round score, 0..8
        COMBINE     = '[VALENTIONE]COMBINE',     -- right half used per whole chocolate, packed base 5 (0 = none)
        INTRO       = '[VALENTIONE]INTRO_SEEN',  -- full moogle explanation already shown once
        ROUNDS_DONE = '[VALENTIONE]ROUNDS_DONE', -- lifetime completed (rewarded) rounds
    },
}

local function loadSettings(currentTable, settingsName)
    local settingTable = xi.settings.main[settingsName]

    if not settingTable then
        if currentTable.ANNOUNCE then
            print('[Valentione] No settings in main.lua, using default')
        end

        return
    else
        if currentTable.ANNOUNCE then
            print('[Valentione] Loading settings from main.lua')
        end
    end

    -- Load from main settings into current table
    for settingName, _ in pairs(currentTable) do
        if settingTable[settingName] then
            currentTable[settingName] = settingTable[settingName]
        end
    end
end

loadSettings(settings, 'VALENTIONE')

xi.events.valentione.enabledCheck = function()
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

event:setEnableCheck(xi.events.valentione.enabledCheck)

-----------------------------------
-- Data
-----------------------------------
-- textBase is the zone text ID of 'Love is in the air! It's time for
-- Valentione's Day celebrations, kupo!'. All other retail lines used by
-- the event sit at fixed offsets from it (verified identical layout in
-- all six city zones via the client DAT dialog tables).

xi.events.valentione.data =
{
    [xi.zone.SOUTHERN_SAN_DORIA] =
    {
        nation   = 0,
        textBase = 10285,
        moogle   = { 194, 56.195, 1.999, -25.207 }, -- !pos 56.195 1.999 -25.207 230
    },

    [xi.zone.NORTHERN_SAN_DORIA] =
    {
        nation   = 0,
        textBase = 14242,
        moogle   = { 128, -224.135, 8.000, 53.476 }, -- !pos -224.135 8.000 53.476 231
    },

    [xi.zone.BASTOK_MINES] =
    {
        nation   = 1,
        textBase = 12471,
        moogle   = { 0, -33.600, -0.001, -110.000 }, -- !pos -33.600 -0.001 -110.000 234
    },

    [xi.zone.BASTOK_MARKETS] =
    {
        nation   = 1,
        textBase = 9129,
        moogle   = { 40, -260.440, -12.021, -79.538 }, -- !pos -260.440 -12.021 -79.538 235
    },

    [xi.zone.WINDURST_WATERS] =
    {
        nation   = 2,
        textBase = 11935,
        moogle   = { 0, -55.470, -5.391, 216.362 }, -- !pos -55.470 -5.391 216.362 238
    },

    [xi.zone.WINDURST_WOODS] =
    {
        nation   = 2,
        textBase = 10184,
        moogle   = { 161, 104.823, -5.000, -55.745 }, -- !pos 104.823 -5.000 -55.745 241
    },
}

-- The 24 hidden Valentione Single NPCs from npc_list.sql, mapped to the
-- retail placement table. The race byte embedded in each row's look
-- string (byte 4: 1 Hume M .. 8 Galka) matches the retail race/sex set
-- for every zone, so it is used as the authoritative per-NPC identity;
-- the retail grid square each NPC corresponds to is noted alongside.
-- Mithra count as female and Galka as male for matching purposes.
xi.events.valentione.singles =
{
    -- Southern San d'Oria (retail: Hume M L-7, Hume F J-8, Elvaan F C-6, Elvaan M E-7)
    [17719656] = xi.race.HUME_M,   -- ( 129.000,  0.000,   74.000) L-7
    [17719657] = xi.race.ELVAAN_M, -- (-160.000, -2.000,   54.000) E-7
    [17719658] = xi.race.HUME_F,   -- (  22.957,  2.101,    5.204) J-8
    [17719659] = xi.race.ELVAAN_F, -- (-260.502, -3.601,  114.618) C-6

    -- Northern San d'Oria (retail: Taru M E-6, Taru F K-9, Mithra H-8, Galka D-9)
    [17723677] = xi.race.TARU_M,   -- (-171.000,  0.000,  132.000) E-6
    [17723678] = xi.race.GALKA,    -- (-225.815,  7.999,   12.659) D-9
    [17723679] = xi.race.TARU_F,   -- (  71.927, -0.199,   38.052) K-9
    [17723680] = xi.race.MITHRA,   -- ( -53.768, -0.199,   74.132) H-8

    -- Bastok Mines (retail: Elvaan M E-8, Elvaan F H-7, Hume M G-8, Hume F I-7)
    [17735876] = xi.race.HUME_M,   -- ( -55.000, -8.000,  -71.000) G-8
    [17735877] = xi.race.ELVAAN_M, -- (-131.000,  0.000,  -70.000) E-8
    [17735878] = xi.race.HUME_F,   -- (  31.969,  0.000,  -24.326) I-7
    [17735879] = xi.race.ELVAAN_F, -- ( -31.000,  0.000,  -27.000) H-7

    -- Bastok Markets (retail: Taru F G-9, Taru M J-10, Mithra G-8, Galka G-4)
    [17739972] = xi.race.TARU_M,   -- (-120.000, -4.000, -131.000) J-10
    [17739973] = xi.race.GALKA,    -- (-253.000,  0.000,   83.000) G-4
    [17739974] = xi.race.TARU_F,   -- (-268.000, -10.000, -105.000) G-9
    [17739975] = xi.race.MITHRA,   -- (-263.874, -12.021, -49.769) G-8

    -- Windurst Waters (retail: Hume M G-10, Hume F J-9, Elvaan F K-6, Elvaan M F-8)
    [17752378] = xi.race.HUME_M,   -- ( -14.610, -1.000,   23.999) G-10
    [17752379] = xi.race.ELVAAN_M, -- ( -46.443, -5.000,   98.456) F-8
    [17752380] = xi.race.HUME_F,   -- (  28.301, -1.250, -220.395) J-9
    [17752381] = xi.race.ELVAAN_F, -- ( 142.420,  0.000,  153.543) K-6

    -- Windurst Woods (retail: Taru F J-6, Taru M H-10, Mithra J-8, Galka G-10)
    [17764623] = xi.race.TARU_M,   -- (  -9.000,  3.000,  -62.000) H-10
    [17764624] = xi.race.GALKA,    -- ( -59.000,  1.000,  -53.000) G-10
    [17764625] = xi.race.TARU_F,   -- (  97.500, -5.000,  116.000) J-6
    [17764626] = xi.race.MITHRA,   -- (  59.600, -5.000,   42.000) J-8
}

-----------------------------------
-- Items
-----------------------------------
-- Chocolate race lines by race index 0..3:
-- 0 Hume (Amour), 1 Elvaan (Romance), 2 Tarutaru (Desire), 3 Galka/Mithra (Attraction)

local leftPieces      = { 2017, 2018, 2019, 2020 } -- amour/romance/desire/attraction chocolate left piece
local rightPiecesMale = { 2021, 2023, 2025, 2027 } -- right pieces handed out by male singles
local rightPiecesFem  = { 2022, 2024, 2026, 2028 } -- right pieces handed out by female singles
local wholeChocolates =
{
    xi.item.AMOUR_CHOCOLATE,
    xi.item.ROMANCE_CHOCOLATE,
    xi.item.DESIRE_CHOCOLATE,
    xi.item.ATTRACTION_CHOCOLATE,
}

local rewardItems =
{
    CHOCOPASS       = 1789,
    CHOCOBO_TICKET  = 1514,
    FIREWORK_FIRST  = 4238,  -- inferno crystal (elemental firework)
    FIREWORK_LAST   = 4245,  -- twilight crystal (elemental firework)
    CHARM_WAND      = 18399,
    CHARM_WAND_P1   = 18400,
    MIRACLE_WAND    = 18844,
    MIRACLE_WAND_P1 = 18845,
    CUPID_CHOCOLATE = 5681,
    HEART_APRON     = 26889,
    HEART_APRON_P1  = 26890,
}

-----------------------------------
-- Messages
-----------------------------------
-- Offsets from each zone's textBase. Quotes are from the Windurst Woods
-- DAT (base 10184); the other five zones carry the identical block.

local messageOffset =
{
    INTRO_FIRST     = 0,  -- Love is in the air! It's time for Valentione's Day celebrations, kupo!
    RULES_FIRST     = 4,  -- Here's what you should do, kupo: Take the two halves of a piece of chocolate from a Valentione Single.
    INTRO_LAST      = 16, -- Or maybe you could take advantage of this romantic occasion and make a party with that special someone...
    TRY_AGAIN       = 17, -- Want to try again? Match up all the lovebirds you can, kupo!
    SOMETHING_WRONG = 18, -- Something wrong, kupo?
    FOUR_PEOPLE     = 20, -- Four people hold the chocolates you seek. Make them into four whole chocolates and give one to each person...
    GIVE_UP_WARN    = 23, -- If you want to start over, you'll have to get rid of the chocolates you have now.
    GIVE_UP_DONE    = 25, -- Just think of all those poor singles! You'll come back and help them later, won't you, kupo?...
    COMBINE_START   = 26, -- You've managed to gather complementary pieces of chocolate! Wait just a moment, now...
    COMBINE_WAIT    = 27, -- ...
    COMBINE_DONE    = 28, -- Kupopopo! What a beautiful piece of chocolate! No need to thank me, now. Hurry and give it to the Valentione Single!
    RESULTS         = 29, -- Great work, kupo! You delivered chocolates to everyone! I've been getting lots of feedback about it! The response has been...
    SCORE_HIGH      = 30, -- Excellent! I thought my heart was going to flutter out of my furry little chest--you score <points> point(s)!...
    SCORE_MID       = 31, -- Decent. You score <points> point(s). Everyone seems relatively happy! Not bad, kupo.
    SCORE_LOW       = 32, -- Well, let's just say that some things just weren't meant to be. You score <points> point(s)...
    PICK_REWARD     = 33, -- My bag is filled with goodies for helpful adventurers like yourself! Take your pick!
    WAIT_LONGER     = 37, -- You must wait a bit longer to try again, kupo.
    THROW_AWAY      = 38, -- You have to throw away all of your chocolates before playing again, kupo! It might seem a waste, but a rule is a rule!
    MALE_GROUPS     = 39, -- First line of the four male singles' 5-line dialog groups
    FEMALE_GROUPS   = 59, -- First line of the four female singles' 5-line dialog groups
}

-- Each single owns a 5-line dialog group selected by their personality.
-- Personality indices follow the client's ${choice} option order:
--   Male   0 Cheerful, 1 Cool-headed, 2 Honest, 3 Shy
--   Female 0 Cheerful, 1 Kind,        2 Shy,    3 Modest
-- Group line offsets:
--   +0 greeting     eg. 'Hiya! I've been waiting for you, sugar!...'
--   +1 preference   eg. 'Listen closely, now! I liiike...<personality> <race> boys!...' (choice params in slots 2 and 3)
--   +2 waiting      eg. 'What's wrong, pumpernickel? Not having trouble, are we?...'
--   +3 idle         eg. 'Hm? Want something? You should go talk to a moogle!'
--   +4 thanks       eg. 'Oh, I've been waiting! I wonder what it tastes like!...'
-- Desired-partner race indices also follow the ${choice} option order:
--   Girls 0 Hume, 1 Elvaan, 2 Tarutaru, 3 Mithra
--   Boys  0 Hume, 1 Elvaan, 2 Tarutaru, 3 Galkan

local groupLine =
{
    GREETING   = 0,
    PREFERENCE = 1,
    WAITING    = 2,
    IDLE       = 3,
    THANKS     = 4,
}

-----------------------------------
-- Helpers
-----------------------------------

local raceIsMale =
{
    [xi.race.HUME_M]   = true,
    [xi.race.HUME_F]   = false,
    [xi.race.ELVAAN_M] = true,
    [xi.race.ELVAAN_F] = false,
    [xi.race.TARU_M]   = true,
    [xi.race.TARU_F]   = false,
    [xi.race.MITHRA]   = false,
    [xi.race.GALKA]    = true,
}

local raceIndex =
{
    [xi.race.HUME_M]   = 0,
    [xi.race.HUME_F]   = 0,
    [xi.race.ELVAAN_M] = 1,
    [xi.race.ELVAAN_F] = 1,
    [xi.race.TARU_M]   = 2,
    [xi.race.TARU_F]   = 2,
    [xi.race.MITHRA]   = 3,
    [xi.race.GALKA]    = 3,
}

local function isMalePlayer(player)
    return player:getGender() == 1 -- Female: 0, Male: 1
end

-- Read digit <index> (0-based) of <value> interpreted in base <base>
local function getDigit(value, index, base)
    local mult = 1

    for _ = 1, index do
        mult = mult * base
    end

    return math.floor(value / mult) % base
end

-- Return <value> with digit <index> (0-based, base <base>) set to <digit>
local function setDigit(value, index, base, digit)
    local mult = 1

    for _ = 1, index do
        mult = mult * base
    end

    return value + (digit - getDigit(value, index, base)) * mult
end

-- Personalities for one sex's four singles, packed base 4 by race index
local function rollPersonalities()
    local packed = 0
    local mult = 1

    for _ = 1, 4 do
        packed = packed + math.random(0, 3) * mult
        mult = mult * 4
    end

    return packed
end

-- Desired race + personality for the four same-sex singles,
-- packed base 16 by race index (digit = race + personality * 4)
local function rollDesires()
    local packed = 0
    local mult = 1

    for _ = 1, 4 do
        packed = packed + (math.random(0, 3) + math.random(0, 3) * 4) * mult
        mult = mult * 16
    end

    return packed
end

local function hasEventChocolate(player)
    for itemId = leftPieces[1], wholeChocolates[4] do
        if player:hasItem(itemId) then
            return true
        end
    end

    return false
end

local function groupBase(textBase, npcMale, personality)
    local sexOffset = messageOffset.FEMALE_GROUPS

    if npcMale then
        sexOffset = messageOffset.MALE_GROUPS
    end

    return textBase + sexOffset + personality * 5
end

local function clearRound(player)
    player:setCharVar(settings.VAR.ROUND, 0)
    player:setCharVar(settings.VAR.PERS_M, 0)
    player:setCharVar(settings.VAR.PERS_F, 0)
    player:setCharVar(settings.VAR.DESIRE, 0)
    player:setCharVar(settings.VAR.HANDOUT, 0)
    player:setCharVar(settings.VAR.RETURNED, 0)
    player:setCharVar(settings.VAR.SCORE, 0)
    player:setCharVar(settings.VAR.COMBINE, 0)
end

local function finishRound(player)
    clearRound(player)
    player:setCharVar(settings.VAR.ROUNDS_DONE, player:getCharVar(settings.VAR.ROUNDS_DONE) + 1)
end

-----------------------------------
-- Round start
-----------------------------------

local function startRound(player, npc, textBase, nation)
    if player:getCharVar(settings.VAR.INTRO) == 0 then
        for line = messageOffset.INTRO_FIRST, messageOffset.INTRO_LAST do
            player:messageText(npc, textBase + line)
        end

        player:setCharVar(settings.VAR.INTRO, 1)
    else
        player:messageText(npc, textBase + messageOffset.TRY_AGAIN)
    end

    clearRound(player)
    player:setCharVar(settings.VAR.DAILY, VanadielUniqueDay())
    player:setCharVar(settings.VAR.ROUND, nation + 1)
    player:setCharVar(settings.VAR.PERS_M, rollPersonalities())
    player:setCharVar(settings.VAR.PERS_F, rollPersonalities())
    player:setCharVar(settings.VAR.DESIRE, rollDesires())
end

-----------------------------------
-- Valentione Single event handlers
-----------------------------------

xi.events.valentione.onSingleTrigger = function(player, npc)
    local race = xi.events.valentione.singles[npc:getID()]
    local zoneData = xi.events.valentione.data[npc:getZoneID()]

    if
        not race or
        not zoneData
    then
        return
    end

    npc:facePlayer(player, true)

    local textBase = zoneData.textBase
    local npcMale = raceIsMale[race]
    local idx = raceIndex[race]
    local round = player:getCharVar(settings.VAR.ROUND)
    local active = round ~= 0 and round - 1 == zoneData.nation

    -- Their rolled personality this round; defaults to Cheerful when
    -- the player has no active round here.
    local personality = 0
    if active then
        local persVar = settings.VAR.PERS_F

        if npcMale then
            persVar = settings.VAR.PERS_M
        end

        personality = getDigit(player:getCharVar(persVar), idx, 4)
    end

    local lines = groupBase(textBase, npcMale, personality)

    -- Singles only work with players of their own sex during a round in
    -- their own city; everyone else gets brushed off.
    if
        not active or
        npcMale ~= isMalePlayer(player)
    then
        player:messageText(npc, lines + groupLine.IDLE)
        return
    end

    if getDigit(player:getCharVar(settings.VAR.RETURNED), idx, 2) == 1 then
        player:messageText(npc, lines + groupLine.IDLE)
    elseif getDigit(player:getCharVar(settings.VAR.HANDOUT), idx, 2) == 1 then
        player:messageText(npc, lines + groupLine.WAITING)
    else
        local desire = getDigit(player:getCharVar(settings.VAR.DESIRE), idx, 16)
        local desiredRace = desire % 4
        local desiredPers = math.floor(desire / 4)
        local rightPiece = rightPiecesFem[idx + 1]

        if npcMale then
            rightPiece = rightPiecesMale[idx + 1]
        end

        player:messageText(npc, lines + groupLine.GREETING)

        -- 'I liiike...<personality> <race> boys!' - choice params sit in
        -- message parameter slots 2 and 3
        player:messageSpecial(lines + groupLine.PREFERENCE, 0, 0, desiredPers, desiredRace)

        -- Both chocolate halves; requires two free inventory slots
        if npcUtil.giveItem(player, { leftPieces[idx + 1], rightPiece }) then
            player:setCharVar(settings.VAR.HANDOUT, setDigit(player:getCharVar(settings.VAR.HANDOUT), idx, 2, 1))
        end
    end
end

xi.events.valentione.onSingleTrade = function(player, npc, trade)
    local race = xi.events.valentione.singles[npc:getID()]
    local zoneData = xi.events.valentione.data[npc:getZoneID()]

    if
        not race or
        not zoneData
    then
        return
    end

    local npcMale = raceIsMale[race]
    local idx = raceIndex[race]
    local round = player:getCharVar(settings.VAR.ROUND)
    local active = round ~= 0 and round - 1 == zoneData.nation

    if
        not active or
        npcMale ~= isMalePlayer(player) or
        getDigit(player:getCharVar(settings.VAR.HANDOUT), idx, 2) == 0 or
        getDigit(player:getCharVar(settings.VAR.RETURNED), idx, 2) == 1 or
        not npcUtil.tradeHasExactly(trade, wholeChocolates[idx + 1])
    then
        return
    end

    npc:facePlayer(player, true)

    local textBase = zoneData.textBase
    local persVar = settings.VAR.PERS_F

    if npcMale then
        persVar = settings.VAR.PERS_M
    end

    local personality = getDigit(player:getCharVar(persVar), idx, 4)
    local lines = groupBase(textBase, npcMale, personality)

    -- Which right half went into this whole chocolate? (0 = the moogles
    -- never combined one for this single's left half this round)
    local combined = getDigit(player:getCharVar(settings.VAR.COMBINE), idx, 5)
    if combined == 0 then
        player:messageText(npc, lines + groupLine.WAITING)
        return
    end

    -- Score the match: the right half identifies the opposite-sex single
    -- who gave it out, by race. Compare that single's race and rolled
    -- personality against this single's desires.
    local giverRace = combined - 1
    local giverPersVar = settings.VAR.PERS_M

    if npcMale then
        giverPersVar = settings.VAR.PERS_F
    end

    local giverPers = getDigit(player:getCharVar(giverPersVar), giverRace, 4)
    local desire = getDigit(player:getCharVar(settings.VAR.DESIRE), idx, 16)
    local desiredRace = desire % 4
    local desiredPers = math.floor(desire / 4)
    local points = 0

    if giverRace == desiredRace then
        points = points + 1
    end

    if giverPers == desiredPers then
        points = points + 1
    end

    player:confirmTrade()
    player:setCharVar(settings.VAR.SCORE, player:getCharVar(settings.VAR.SCORE) + points)
    player:setCharVar(settings.VAR.RETURNED, setDigit(player:getCharVar(settings.VAR.RETURNED), idx, 2, 1))
    player:messageText(npc, lines + groupLine.THANKS)
end

-----------------------------------
-- Moogle reward menu
-----------------------------------

local function claimReward(player, npc, itemId)
    if npcUtil.giveItem(player, itemId) then
        finishRound(player)
    end
end

local function showRewardMenu(player, npc, textBase)
    local score = player:getCharVar(settings.VAR.SCORE)
    local percent = score * 100 / 8

    local options =
    {
        {
            'Let me think.',
            function(playerArg)
            end,
        },
        {
            'A chocopass.',
            function(playerArg)
                claimReward(playerArg, npc, rewardItems.CHOCOPASS)
            end,
        },
    }

    if percent >= 39 then
        table.insert(options,
        {
            'A chocobo ticket.',
            function(playerArg)
                claimReward(playerArg, npc, rewardItems.CHOCOBO_TICKET)
            end,
        })
    end

    if percent >= 49 then
        table.insert(options,
        {
            'An elemental firework.',
            function(playerArg)
                claimReward(playerArg, npc, math.random(rewardItems.FIREWORK_FIRST, rewardItems.FIREWORK_LAST))
            end,
        })
    end

    if percent >= 66 then
        table.insert(options,
        {
            'A charm wand.',
            function(playerArg)
                -- Wielding the NQ wand while claiming upgrades it to +1
                local wandId = rewardItems.CHARM_WAND

                if playerArg:getEquipID(xi.slot.MAIN) == rewardItems.CHARM_WAND then
                    wandId = rewardItems.CHARM_WAND_P1
                end

                claimReward(playerArg, npc, wandId)
            end,
        })

        table.insert(options,
        {
            'A miracle wand.',
            function(playerArg)
                local wandId = rewardItems.MIRACLE_WAND

                if playerArg:getEquipID(xi.slot.MAIN) == rewardItems.MIRACLE_WAND then
                    wandId = rewardItems.MIRACLE_WAND_P1
                end

                claimReward(playerArg, npc, wandId)
            end,
        })
    end

    if percent >= 77 then
        table.insert(options,
        {
            'A serving of cupid chocolate.',
            function(playerArg)
                claimReward(playerArg, npc, rewardItems.CUPID_CHOCOLATE)
            end,
        })
    end

    if
        percent >= 77 and
        player:getCharVar(settings.VAR.ROUNDS_DONE) >= 3
    then
        table.insert(options,
        {
            'A heart apron.',
            function(playerArg)
                -- Wearing the NQ apron while claiming upgrades it to +1
                local apronId = rewardItems.HEART_APRON

                if playerArg:getEquipID(xi.slot.BODY) == rewardItems.HEART_APRON then
                    apronId = rewardItems.HEART_APRON_P1
                end

                claimReward(playerArg, npc, apronId)
            end,
        })
    end

    player:customMenu(
    {
        title   = 'Which item would you like?',
        options = options,
    })
end

local function showResults(player, npc, textBase)
    local score = player:getCharVar(settings.VAR.SCORE)
    local percent = score * 100 / 8

    player:messageText(npc, textBase + messageOffset.RESULTS)

    -- 'you score <points> point(s)' - the number sits in parameter slot 2
    if percent >= 77 then
        player:messageSpecial(textBase + messageOffset.SCORE_HIGH, 0, 0, score)
    elseif percent >= 39 then
        player:messageSpecial(textBase + messageOffset.SCORE_MID, 0, 0, score)
    else
        player:messageSpecial(textBase + messageOffset.SCORE_LOW, 0, 0, score)
    end

    player:messageText(npc, textBase + messageOffset.PICK_REWARD)
    showRewardMenu(player, npc, textBase)
end

-----------------------------------
-- Moogle mid-round menu
-----------------------------------

local function confirmGiveUp(player, npc, textBase)
    player:messageText(npc, textBase + messageOffset.GIVE_UP_WARN)

    player:customMenu(
    {
        title   = 'Really give up?',
        options =
        {
            {
                'Yes!',
                function(playerArg)
                    clearRound(playerArg)
                    playerArg:messageText(npc, textBase + messageOffset.GIVE_UP_DONE)
                end,
            },
            {
                'No, not yet!',
                function(playerArg)
                    playerArg:messageText(npc, textBase + messageOffset.FOUR_PEOPLE)
                end,
            },
        },
    })
end

local function showStatusMenu(player, npc, textBase)
    player:messageText(npc, textBase + messageOffset.SOMETHING_WRONG)

    player:customMenu(
    {
        title   = 'Something wrong?',
        options =
        {
            {
                'Listen to the rules again.',
                function(playerArg)
                    for line = messageOffset.RULES_FIRST, messageOffset.INTRO_LAST do
                        playerArg:messageText(npc, textBase + line)
                    end
                end,
            },
            {
                'Give up.',
                function(playerArg)
                    -- Reopening a menu from inside a menu callback needs
                    -- a short delay (see adventurer_appreciation.lua)
                    playerArg:timer(50, function(timerArg)
                        confirmGiveUp(timerArg, npc, textBase)
                    end)
                end,
            },
            {
                'Not really.',
                function(playerArg)
                    playerArg:messageText(npc, textBase + messageOffset.FOUR_PEOPLE)
                end,
            },
        },
    })
end

-----------------------------------
-- Moogle event handlers
-----------------------------------

xi.events.valentione.onMoogleTrigger = function(player, npc)
    local zoneData = xi.events.valentione.data[player:getZoneID()]
    if not zoneData then
        return
    end

    npc:facePlayer(player, true)

    local textBase = zoneData.textBase
    local round = player:getCharVar(settings.VAR.ROUND)

    if round == 0 then
        if hasEventChocolate(player) then
            player:messageText(npc, textBase + messageOffset.THROW_AWAY)
        elseif player:getCharVar(settings.VAR.DAILY) >= VanadielUniqueDay() then
            player:messageText(npc, textBase + messageOffset.WAIT_LONGER)
        else
            startRound(player, npc, textBase, zoneData.nation)
        end
    elseif round - 1 ~= zoneData.nation then
        -- No retail line covers rounds spanning cities; keep it clear
        player:printToPlayer('Your matchmaking round is underway in another city, kupo! Finish up there first!', xi.msg.channel.NS_SAY, 'Moogle')
    elseif player:getCharVar(settings.VAR.RETURNED) == 15 then
        showResults(player, npc, textBase)
    else
        showStatusMenu(player, npc, textBase)
    end
end

xi.events.valentione.onMoogleTrade = function(player, npc, trade)
    local zoneData = xi.events.valentione.data[player:getZoneID()]
    if not zoneData then
        return
    end

    local round = player:getCharVar(settings.VAR.ROUND)
    if
        round == 0 or
        round - 1 ~= zoneData.nation
    then
        return
    end

    npc:facePlayer(player, true)

    local textBase = zoneData.textBase
    local handout = player:getCharVar(settings.VAR.HANDOUT)
    local returned = player:getCharVar(settings.VAR.RETURNED)
    local rightList = rightPiecesMale

    -- Combine with a right half from the opposite sex only
    if isMalePlayer(player) then
        rightList = rightPiecesFem
    end

    for leftIdx = 0, 3 do
        if
            getDigit(handout, leftIdx, 2) == 1 and
            getDigit(returned, leftIdx, 2) == 0
        then
            for rightIdx = 0, 3 do
                if npcUtil.tradeHasExactly(trade, { leftPieces[leftIdx + 1], rightList[rightIdx + 1] }) then
                    player:messageText(npc, textBase + messageOffset.COMBINE_START)
                    player:messageText(npc, textBase + messageOffset.COMBINE_WAIT)
                    player:messageText(npc, textBase + messageOffset.COMBINE_DONE)

                    if npcUtil.giveItem(player, wholeChocolates[leftIdx + 1]) then
                        player:confirmTrade()
                        player:setCharVar(settings.VAR.COMBINE, setDigit(player:getCharVar(settings.VAR.COMBINE), leftIdx, 5, rightIdx + 1))
                    end

                    return
                end
            end
        end
    end
end

-----------------------------------
-- Show/hide Moogles and Singles
-----------------------------------

local function insertMoogle(zone, pos)
    local npc = zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'Valentione_Moogle',
        packetName = 'Moogle',
        look       = 82,
        x          = pos[2],
        y          = pos[3],
        z          = pos[4],
        rotation   = pos[1],
        onTrigger  = xi.events.valentione.onMoogleTrigger,
        onTrade    = xi.events.valentione.onMoogleTrade,
        releaseIdOnDisappear = true,
    })

    table.insert(xi.events.valentione.entities, npc:getID())
end

xi.events.valentione.generateEntities = function()
    for zoneID, zoneData in pairs(xi.events.valentione.data) do
        local zone = GetZone(zoneID)
        if zone then
            insertMoogle(zone, zoneData.moogle)
        end
    end
end

xi.events.valentione.showEntities = function(enabled)
    if
        enabled and
        #xi.events.valentione.entities == 0
    then
        xi.events.valentione.generateEntities()
    end

    -- Dynamic Event Moogles
    for _, entityID in pairs(xi.events.valentione.entities) do
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
        xi.events.valentione.entities = {}
    end

    -- Static Valentione Singles (hidden in npc_list.sql outside the event)
    for npcId, _ in pairs(xi.events.valentione.singles) do
        local single = GetNPCByID(npcId)
        if single then
            if enabled then
                single:setStatus(xi.status.NORMAL)
            else
                single:setStatus(xi.status.DISAPPEAR)
            end
        end
    end
end

event:setStartFunction(function()
    xi.events.valentione.showEntities(true)
end)

event:setEndFunction(function()
    xi.events.valentione.showEntities(false)
end)

event.serverMessage =
    'Valentione\'s Day is here! Speak to the Event Moogles in the six nation cities ' ..
    'to play matchmaker for the Valentione Singles, kupo!'

return event
