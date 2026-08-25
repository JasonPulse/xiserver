-----------------------------------
-- Monster Rearing (Mog Garden)
-----------------------------------
-- Chacharoon keeps creatures for you in the Mog Garden. You interact with them
-- once a day, feed them, and collect from them. Interactions raise a Monster
-- Rearing rank of 1 to 7, rank governs how many creatures you may keep and
-- opens the Rearing Grounds, and a creature raised far enough yields a Memento
-- key item whose Cheer can then be worn as a bonus.
--
-- Sources. The mechanics are bg-wiki "Monster Rearing". The creature tables are
-- generated into monster_rearing_data.lua; read that file's header for how the
-- wiki tables and the client's own menus were joined. Every line of text below
-- is the client's own wording, taken from dialog-table-280.xml at the message id
-- named beside it.
--
-- ENTITIES. The five rearing pens are 17924233 through 17924237 and their
-- npc_list `name` column is the single byte 0x01, so getName() hands back "\1"
-- and luautils::OnEntityLoad refuses to look for a script file (it skips any
-- name that is not printable). They are therefore wired through the zone's
-- DefaultActions.lua under that one-byte key and told apart by entity id here.
-- Searching npc_list by name reports that no such NPC exists; only
-- polutils_name says "Breeding Monster".
--
--   17924233  main garden, shows whichever creature is the rearing priority
--   17924237  rearing grounds pen for slot 1        (polutils "Breeding Monster00")
--   17924234  rearing grounds pen for slot 2        (polutils "Breeding Monster01")
--   17924235  rearing grounds pen for slot 3        (polutils "Breeding Monster02")
--   17924236  rearing grounds pen for slot 4        (polutils "Breeding Monster03")
--
-- Chacharoon stands twice: 17924231 in the main garden and 17924232 in the
-- Rearing Grounds. Both carry the same 13.5KB event program, entered at csid
-- 1075 and 1088 respectively. Both were fired at the puppet and both render
-- "Today <name> is talk to Chacharoon why?", which is message 8601, the line the
-- options menu opens on. 1081 renders "You gave  ." and "stares off into the
-- distance as if you're not even there", the feed and neutral-reaction lines of
-- the pen care event.
--
-- THE UI IS THE RETAIL EVENT. Chacharoon's options are csid 1075 in the garden
-- and 1088 in the Rearing Grounds, and a pen's care menu is 1076 through 1080;
-- all seven are confirmed live. The client owns the whole menu tree and draws
-- every window from its own bytecode, so the server supplies the state the
-- program reads, answers each yield, and performs what the client asks for. See
-- "The retail event layer" below for the decoded parameter layout and for the
-- one thing that is not decoded.
--
-- NUMBERS THAT ARE OURS. bg-wiki publishes no growth rate, no memento drop
-- chance, no moogle magic price and no cheer price. Everything under "Tuning"
-- below is our figure, in the same spirit as martello.lua's regeneration rate.
-- Everything else, including which food a creature eats, which interaction
-- resonates with it, what it evolves into and what it hands over, is retail.
-----------------------------------
require('scripts/globals/monster_rearing_data')
require('scripts/globals/npc_util')
require('scripts/globals/quests')
-----------------------------------

xi = xi or {}
xi.monsterRearing = xi.monsterRearing or {}

-----------------------------------
-- Entities
-----------------------------------

xi.monsterRearing.npc =
{
    CHACHAROON_GARDEN  = 17924231,
    CHACHAROON_REARING = 17924232,
    PEN_PRIORITY       = 17924233,
}

-- Rearing grounds pen entity id per creature slot.
local penBySlot =
{
    [1] = 17924237,
    [2] = 17924234,
    [3] = 17924235,
    [4] = 17924236,
}

local slotByPen = {}
for slot, penId in pairs(penBySlot) do
    slotByPen[penId] = slot
end

-- Where "Move to a different location." puts you. The Rearing Grounds sit at the
-- far end of the same zone, which is why retail ferries you rather than letting
-- you walk: Chacharoon stands at 355.5/-3.0/-547.8 there and at -12.0/0.5/7.4 in
-- the garden proper.
local travel =
{
    garden  = { x = -10.100, y =  0.500, z =   7.354, rot = 190, label = 'the Mog Garden' },
    rearing = { x = 355.490, y = -3.040, z = -545.000, rot =  64, label = 'the rearing grounds' },
}

-----------------------------------
-- Tuning. Ours, not retail's; bg-wiki gives no figures for any of these.
-----------------------------------

local growthPerStar     = 100  -- growth points in one star step, 6 steps to ***
local growthPerDay      = 20   -- personal growth, per Earth day
local growthPerFeed     = 25   -- any food
local growthFeedJubilee = 50   -- Jubilee Shirt doubles feeding progress (retail)
local mementoChanceBase = 8    -- percent at ***, before growth
local mementoChanceStep = 7    -- percent added per star of growth
local moogleMagicBase   = 3    -- shining stars for the first calming
local moogleMagicStep   = 2    -- added per previous calming of the same creature
local cheerChangeCost   = 3    -- shining stars to switch the active cheer
local evolveChance      = 25   -- percent, per feed of a qualifying evolution food

-----------------------------------
-- Scales
-----------------------------------

local maxGrowth = growthPerStar * 6

local mood =
{
    DARKNESS   = 0,
    POUTING    = 1,
    CALM       = 2,
    GOOD       = 3,
    JOYFUL     = 4,
    CONTENTED  = 5,
}

local style =
{
    GROWTH = 1,
    MOMENT = 2,
}

-----------------------------------
-- State
-----------------------------------

local focusVar  = 'MonsterRearing_Focus'
local cheerVar  = 'MonsterRearing_Cheer'
local newDayVar = 'MonsterRearing_NewDay'
local lastFedVar = 'MonsterRearing_LastFed'
local contentVar = 'MonsterRearing_ContentBonus'

local function slotVar(slot, suffix)
    return string.format('MonsterRearing_S%d_%s', slot, suffix)
end

local function earthDay()
    return math.floor(GetSystemTime() / 86400)
end

--- The creature in a slot, or nil when the slot is empty.
---@param player CBaseEntity
---@param slot integer
---@return table?
local function readSlot(player, slot)
    local formId = player:getCharVar(slotVar(slot, 'Form'))
    if formId == 0 or not xi.monsterRearing.forms[formId] then
        return nil
    end

    local acts = player:getCharVar(slotVar(slot, 'Acts'))

    return {
        slot    = slot,
        formId  = formId,
        form    = xi.monsterRearing.forms[formId],
        growth  = player:getCharVar(slotVar(slot, 'Growth')),
        mood    = player:getCharVar(slotVar(slot, 'Mood')),
        style   = player:getCharVar(slotVar(slot, 'Style')),
        magic   = player:getCharVar(slotVar(slot, 'Magic')),
        pending = player:getCharVar(slotVar(slot, 'Evo')),
        tick    = player:getCharVar(slotVar(slot, 'Tick')),
        actDay  = math.floor(acts / 8),
        actBits = acts % 8,
    }
end

local function writeSlot(player, creature)
    local slot = creature.slot
    player:setCharVar(slotVar(slot, 'Form'), creature.formId)
    player:setCharVar(slotVar(slot, 'Growth'), creature.growth)
    player:setCharVar(slotVar(slot, 'Mood'), creature.mood)
    player:setCharVar(slotVar(slot, 'Style'), creature.style)
    player:setCharVar(slotVar(slot, 'Magic'), creature.magic)
    player:setCharVar(slotVar(slot, 'Evo'), creature.pending)
    player:setCharVar(slotVar(slot, 'Tick'), creature.tick)
    player:setCharVar(slotVar(slot, 'Acts'), creature.actDay * 8 + creature.actBits)
end

local function clearSlot(player, slot)
    for _, suffix in ipairs({ 'Form', 'Growth', 'Mood', 'Style', 'Magic', 'Evo', 'Tick', 'Acts' }) do
        player:setCharVar(slotVar(slot, suffix), 0)
    end
end

--- Monster Rearing rank, 1 to 7. It is the sixth Mog Garden location, so the
--- Sakura books, their prices and their "care for creatures <n> times" gates all
--- live in mog_garden.lua beside the other five.
---@param player CBaseEntity
---@return integer
xi.monsterRearing.rank = function(player)
    return xi.mog_garden.locationRank(player, xi.mog_garden.location.REARING)
end

--- How many creatures may be kept at once. Rank 3 adds a second, rank 5 a third
--- and rank 7 a fourth.
---@param player CBaseEntity
---@return integer
xi.monsterRearing.maxCreatures = function(player)
    local rank = xi.monsterRearing.rank(player)
    if rank >= 7 then
        return 4
    elseif rank >= 5 then
        return 3
    elseif rank >= 3 then
        return 2
    end

    return 1
end

--- Lifetime count of interactions, which is what the Sakura books are sold
--- against. Feeding and collecting do not count towards it, which is bg-wiki's
--- own emphasis.
---@param player CBaseEntity
---@return integer
xi.monsterRearing.careCount = function(player)
    return xi.mog_garden.interactionCount(player, xi.mog_garden.location.REARING)
end

--- bg-wiki's entry condition for the quest line: "Have all gathering locations at
--- a combined total ranking of twenty or higher."
---@param player CBaseEntity
---@return boolean
xi.monsterRearing.eligible = function(player)
    local total = 0
    for _, location in ipairs({
        xi.mog_garden.location.FURROW,
        xi.mog_garden.location.GROVE,
        xi.mog_garden.location.VEIN,
        xi.mog_garden.location.POND,
        xi.mog_garden.location.COAST,
    }) do
        total = total + xi.mog_garden.locationRank(player, location)
    end

    return total >= 20
end

--- True once Cry Not, Caretaker has been finished, which is where retail says
--- Monster Rearing is fully unlocked.
---@param player CBaseEntity
---@return boolean
xi.monsterRearing.unlocked = function(player)
    return player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CRY_NOT_CARETAKER) == xi.questStatus.QUEST_COMPLETED
end

--- True once the player holds "Sakura and the Fountain", which is what opens the
--- Rearing Grounds.
---@param player CBaseEntity
---@return boolean
xi.monsterRearing.hasRearingGrounds = function(player)
    return xi.monsterRearing.rank(player) >= 3
end

--- The creature currently kept in the main garden, or nil.
---@param player CBaseEntity
---@return table?
xi.monsterRearing.focused = function(player)
    local focus = player:getCharVar(focusVar)
    if focus < 1 or focus > 4 then
        return nil
    end

    return readSlot(player, focus)
end

--- Every creature the player is keeping, in slot order.
---@param player CBaseEntity
---@return table[]
xi.monsterRearing.creatures = function(player)
    local list = {}
    for slot = 1, 4 do
        local creature = readSlot(player, slot)
        if creature then
            list[#list + 1] = creature
        end
    end

    return list
end

--- Item id of the last thing fed to any creature. Release the Fleece and Feeding
--- Frenzy both key a step off a specific feed.
---@param player CBaseEntity
---@return integer
xi.monsterRearing.lastFedItem = function(player)
    return player:getCharVar(lastFedVar)
end

--- True while any creature has succumbed to darkness, which retail says shuts
--- down every gathering node except the Flotsam on the beach.
---@param player CBaseEntity
---@return boolean
xi.monsterRearing.nodesBlocked = function(player)
    for _, creature in ipairs(xi.monsterRearing.creatures(player)) do
        if creature.mood == mood.DARKNESS then
            return true
        end
    end

    return false
end

-----------------------------------
-- Text
-----------------------------------

-- GP_SERV_COMMAND_CHAT_STD carries 150 bytes of message and the client drops the
-- rest, so retail's longer lines have to go out in pieces.
local chatBudget = 140

local function say(player, text, speaker)
    local channel = speaker and xi.msg.channel.SAY or xi.msg.channel.NS_SAY

    while #text > chatBudget do
        local cut = chatBudget
        while cut > 1 and text:sub(cut, cut) ~= ' ' do
            cut = cut - 1
        end

        if cut <= 1 then
            cut = chatBudget
        end

        player:printToPlayer(text:sub(1, cut - 1), channel, speaker or '')
        text = text:sub(cut + 1)
    end

    player:printToPlayer(text, channel, speaker or '')
end

--- getName() returns the internal snake_case name, so make it readable.
---@param itemId integer
---@return string
local function itemName(itemId)
    local item = GetItemByID(itemId)
    if not item then
        return 'something'
    end

    local words = {}
    for word in item:getName():gmatch('[^_]+') do
        words[#words + 1] = string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
    end

    return table.concat(words, ' ')
end

local function chacha(player, text)
    say(player, text, 'Chacharoon')
end

xi.monsterRearing.say = say

-----------------------------------
-- Shining stars
-----------------------------------

local function stars(player)
    return player:getCurrency('shining_star')
end

local function spendStars(player, amount)
    if stars(player) < amount then
        -- 8619
        say(player, 'You do not have enough shining stars.')
        return false
    end

    player:delCurrency('shining_star', amount)
    return true
end

-----------------------------------
-- Creature description
-----------------------------------

local moodLine =
{
    -- 8710, 8709, 8708, 8707, 8706
    [mood.DARKNESS]  = '%s looks like it wants absolutely nothing to do with anyone.',
    [mood.POUTING]   = '%s seems to be pouting slightly.',
    [mood.CALM]      = '%s looks calm and collected.',
    [mood.GOOD]      = '%s\'s in an obviously good mood.',
    [mood.JOYFUL]    = '%s\'s practically bursting with joy!',
    -- 8738
    [mood.CONTENTED] = '%s\'s face beams with the light of pure contentment! There is nothing that can foul %s\'s mood right now, including gathering items from it.',
}

-- 8715 down to 8711.
local contentLine =
{
    [mood.DARKNESS]  = 'Moreover, it seems thoroughly depressed about the abysmal conditions under which it lives.',
    [mood.POUTING]   = 'Moreover, it is clearly unhappy with the way things are.',
    [mood.CALM]      = 'Moreover, it exudes a slight aura of discontent.',
    [mood.GOOD]      = 'Moreover, it seems to be duly satisfied with its lot in life.',
    [mood.JOYFUL]    = 'Moreover, it couldn\'t be more content with its life.',
    [mood.CONTENTED] = 'Moreover, it couldn\'t be more content with its life.',
}

-- 8717's own choice list.
local growthStars =
{
    [0] = '...',
    [1] = '*..',
    [2] = 'X..',
    [3] = 'X*.',
    [4] = 'XX.',
    [5] = 'XX*',
    [6] = 'XXX',
}

local function starsOf(creature)
    return math.min(6, math.floor(creature.growth / growthPerStar))
end

local function describe(player, creature)
    local name = creature.form.name

    if creature.mood == mood.CONTENTED then
        say(player, string.format(moodLine[mood.CONTENTED], name, name))
    else
        say(player, string.format(moodLine[creature.mood], name))
        say(player, contentLine[creature.mood])
    end

    -- 8717
    say(player, string.format('Current growth level: %s.', growthStars[starsOf(creature)]))

    -- 8716
    local collect = creature.form.collectItem
    if collect then
        say(player, string.format('By collecting from this monster, you may very well get your hands on %s.', itemName(collect)))
    end
end

-----------------------------------
-- Daily tick
-----------------------------------

local function eligibleToEvolve(creature)
    local family = xi.monsterRearing.families[creature.form.family]
    local needed = family.lateStar and 5 or 3
    return starsOf(creature) >= needed
end

local function naturalTarget(creature)
    for _, evolution in ipairs(creature.form.evolutions) do
        if evolution.natural then
            return evolution
        end
    end

    return nil
end

--- Advance every creature to today. Personal growth matures the creature and
--- lets its mood slide; enjoying the moment holds both still. Retail applies a
--- pending evolution on the next zone-in, which is what `pending` carries.
---@param player CBaseEntity
---@return nil
local function runDailyTick(player)
    local today = earthDay()
    local contented = 0

    for slot = 1, 4 do
        local creature = readSlot(player, slot)
        if creature then
            if creature.pending ~= 0 and xi.monsterRearing.forms[creature.pending] then
                local grown = xi.monsterRearing.forms[creature.pending]
                say(player, string.format('%s has become a %s!', creature.form.name, grown.name))
                creature.formId  = creature.pending
                creature.form    = grown
                creature.pending = 0
            end

            local elapsed = creature.tick == 0 and 0 or today - creature.tick
            if elapsed > 0 then
                if creature.style == style.GROWTH then
                    creature.growth = math.min(maxGrowth, creature.growth + growthPerDay * elapsed)
                    creature.mood   = math.max(mood.DARKNESS, creature.mood - elapsed)

                    -- "The creature will gradually mature over time." A form
                    -- with a default branch takes it on its own once it is big
                    -- enough; enjoying the moment is what holds it back.
                    if
                        creature.pending == 0 and
                        eligibleToEvolve(creature)
                    then
                        local target = naturalTarget(creature)
                        if
                            target and
                            math.random(100) <= evolveChance
                        then
                            creature.pending = target.form
                        end
                    end
                end

                creature.tick = today
                writeSlot(player, creature)
            elseif creature.tick == 0 then
                creature.tick = today
                writeSlot(player, creature)
            end

            if creature.mood == mood.CONTENTED then
                contented = contented + 1
            end
        end
    end

    -- Two or more contented creatures award an extra shining star the first time
    -- the garden is entered on an Earth day.
    if
        contented >= 2 and
        player:getCharVar(contentVar) < today
    then
        player:setCharVar(contentVar, today)
        player:addCurrency('shining_star', 1)
        say(player, 'The contentment of your creatures lights an extra star in your GPS crystal.')
    end

    if xi.monsterRearing.nodesBlocked(player) then
        -- 8730
        say(player, 'Pardon my perilous proclamation, but your bestial buddy has become a blight on this backyard of bounties! At this rate, you\'ll be hard-pressed to have a harvest at all, kupo!', 'Green Thumb Moogle')
    end
end

xi.monsterRearing.onZoneIn = function(player)
    if not xi.monsterRearing.unlocked(player) then
        return
    end

    runDailyTick(player)
end

-----------------------------------
-- Cheer
-----------------------------------

--- Key item id of the cheer the player is currently wearing, or 0.
---@param player CBaseEntity
---@return integer
xi.monsterRearing.activeCheer = function(player)
    return player:getCharVar(cheerVar)
end

--- Put the active cheer's mods on the player. Called on login and whenever the
--- cheer changes.
--- This only ever adds. addMod is runtime state that dies with the session, so on
--- login there is nothing to take off, and delMod SUBTRACTS rather than clears: a
--- blanket sweep over every cheer's mods drove a fresh character's ATTP negative
--- and broke the Boost test's "no ATTP bonus" precondition. Removing the outgoing
--- cheer is setCheer's job, because that is the only moment one is really worn.
---@param player CBaseEntity
---@return nil
xi.monsterRearing.applyCheer = function(player)
    local mods = xi.monsterRearing.cheerMods[player:getCharVar(cheerVar)]
    if not mods then
        return
    end

    for _, entry in ipairs(mods) do
        player:addMod(entry[1], entry[2])
    end
end

local function setCheer(player, cheerKeyItem)
    local previous = xi.monsterRearing.cheerMods[player:getCharVar(cheerVar)]
    if previous then
        for _, entry in ipairs(previous) do
            player:delMod(entry[1], entry[2])
        end
    end

    player:setCharVar(cheerVar, cheerKeyItem)
    xi.monsterRearing.applyCheer(player)
end

xi.monsterRearing.setCheer = setCheer

-----------------------------------
-- Mementos
-----------------------------------

local function grantMemento(player, creature)
    if player:hasKeyItem(creature.formId) then
        return false
    end

    npcUtil.giveKeyItem(player, creature.formId)
    return true
end

local function mementoRoll(creature)
    return mementoChanceBase + mementoChanceStep * starsOf(creature)
end

-----------------------------------
-- Interacting
-----------------------------------

local function resonates(creature, action)
    for _, liked in ipairs(creature.form.interactions) do
        if liked == action then
            return true
        end
    end

    return false
end

local function markAction(creature, bit)
    local today = earthDay()
    if creature.actDay ~= today then
        creature.actDay  = today
        creature.actBits = 0
    end

    creature.actBits = creature.actBits + bit
end

local function actionDone(creature, bit)
    return creature.actDay == earthDay() and creature.actBits % (bit * 2) >= bit
end

local actInteract = 1
local actFeed     = 2
local actCollect  = 4

local function doInteract(player, creature, action)
    if actionDone(creature, actInteract) then
        -- 8719
        say(player, string.format('%s stares off into the distance as if you\'re not even there.', creature.form.name))
        return
    end

    markAction(creature, actInteract)
    xi.mog_garden.recordInteraction(player, xi.mog_garden.location.REARING, 1)

    if resonates(creature, action) then
        -- 8723
        say(player, string.format('That strongly resonated with %s!', creature.form.name))
        creature.mood = math.min(mood.CONTENTED, creature.mood + 2)

        if creature.mood == mood.CONTENTED then
            player:addCurrency('shining_star', 1)
            if grantMemento(player, creature) then
                -- retail always hands the memento over on a resonating
                -- interaction while the creature is contented
                creature.mood = mood.CONTENTED
            end
        end
    elseif action == xi.monsterRearing.interaction.ANGRY then
        -- 8720
        say(player, string.format('%s is visibly angry with what you just did.', creature.form.name))
        creature.mood = math.max(mood.DARKNESS, creature.mood - 2)
    elseif #creature.form.interactions == 0 then
        -- Families bg-wiki marks "None (-)" dislike everything.
        -- 8721
        say(player, string.format('That didn\'t go over too well with %s.', creature.form.name))
        creature.mood = math.max(mood.DARKNESS, creature.mood - 1)
    else
        -- 8722
        say(player, string.format('That was surprisingly not worthless in the eyes of %s!', creature.form.name))
        creature.mood = math.min(mood.JOYFUL, creature.mood + 1)
    end

    writeSlot(player, creature)
end

-----------------------------------
-- Feeding
-----------------------------------

--- Trade path. Retail feeds a creature by handing it the food, which is why
--- Feeding Frenzy reads "Feed (trade) the sheep the La Theine Cabbage".
---@param player CBaseEntity
---@param creature table
---@param itemId integer
---@return boolean fed
local function doFeed(player, creature, itemId)
    local group = xi.monsterRearing.foodGroup[itemId]
    if not group then
        return false
    end

    if actionDone(creature, actFeed) then
        say(player, string.format('%s has already been fed today.', creature.form.name))
        return false
    end

    markAction(creature, actFeed)
    player:setCharVar(lastFedVar, itemId)

    -- 8739
    say(player, string.format('You gave %s %s.', creature.form.name, itemName(itemId)))

    local gain = growthPerFeed
    if player:getEquipID(xi.slot.BODY) == xi.item.JUBILEE_SHIRT then
        gain = growthFeedJubilee
    end

    creature.growth = math.min(maxGrowth, creature.growth + gain)

    local accepted = false
    for _, foodType in ipairs(creature.form.foodTypes) do
        if foodType == group then
            accepted = true
            break
        end
    end

    local resonating = false
    for _, foodType in ipairs(creature.form.resonating) do
        if foodType == group then
            resonating = true
            break
        end
    end

    if resonating then
        creature.mood = math.min(mood.CONTENTED, creature.mood + 2)
    elseif accepted then
        creature.mood = math.min(mood.JOYFUL, creature.mood + 1)
    end

    -- Evolution. A food that selects a branch only does anything once the
    -- creature has grown far enough, and even then retail says it can take
    -- weeks of trying.
    if
        eligibleToEvolve(creature) and
        creature.pending == 0
    then
        for _, evolution in ipairs(creature.form.evolutions) do
            if evolution.food == itemId then
                -- 8744
                say(player, string.format('%s squirms uncontrollably.', creature.form.name))
                if math.random(100) <= evolveChance then
                    -- 8745
                    say(player, string.format('%s shudders violently.', creature.form.name))
                    creature.pending = evolution.form
                end

                break
            end
        end
    end

    writeSlot(player, creature)
    return true
end

-----------------------------------
-- Collecting
-----------------------------------

local function doCollect(player, creature)
    if actionDone(creature, actCollect) then
        say(player, string.format('%s has nothing more to give today.', creature.form.name))
        return
    end

    markAction(creature, actCollect)

    local contented = creature.mood == mood.CONTENTED
    local item      = creature.form.collectItem

    if item then
        npcUtil.giveItem(player, { { item, 1 + math.floor(starsOf(creature) / 3) } })
    end

    if contented or math.random(100) <= mementoRoll(creature) then
        grantMemento(player, creature)
    end

    -- Collecting always costs mood, unless the creature is beaming.
    if not contented then
        creature.mood = math.max(mood.DARKNESS, creature.mood - 1)
    end

    writeSlot(player, creature)
end

-----------------------------------
-- Parting ways
-----------------------------------

-- bg-wiki names these as the pool for "Send it back home".
local sendHomeItems =
{
    xi.item.VIAL_OF_COALITION_SERUM,
    xi.item.CLUMP_OF_COALITION_HUMUS,
    xi.item.BOTTLE_OF_STAR_SPRINKLES,
    xi.item.SUPER_BAITBALL,
    xi.item.BAG_OF_CACTUS_STEMS,
    xi.item.BAG_OF_TREE_CUTTINGS,
}

local function sendHome(player, creature)
    -- 8677
    chacha(player, string.format('%s embiiiggened Chacharoon and your hearts. Wh-when think must say bye-bye...Ch-Chacharoon...get the snurks...', creature.form.name))

    local payout = 500 * (1 + starsOf(creature))
    player:addGil(payout)
    player:messageSpecial(zones[xi.zone.MOG_GARDEN].text.GIL_OBTAINED, payout)

    -- "up to four Mog Garden related items ... will vary depending on the
    -- monster's maturation and/or affection levels"
    local count = math.min(4, 1 + math.floor((starsOf(creature) + creature.mood) / 3))
    for _ = 1, count do
        npcUtil.giveItem(player, sendHomeItems[math.random(#sendHomeItems)])
    end

    clearSlot(player, creature.slot)
    -- 8682
    say(player, string.format('You and %s have parted ways for all eternity.', creature.form.name))
end

local function putDown(player, creature)
    -- 8680, 8681
    chacha(player, string.format('<Snurk> Chacharoon...will not be forgetting %s...<snurk> ever. Waaaaaah!', creature.form.name))

    if creature.form.collectItem then
        npcUtil.giveItem(player, { { creature.form.collectItem, 2 } })
    end

    npcUtil.giveItem(player, xi.item.VIAL_OF_BEASTMAN_BLOOD)

    clearSlot(player, creature.slot)
    -- 8682
    say(player, string.format('You and %s have parted ways for all eternity.', creature.form.name))
end

-----------------------------------
-- Slots and naming
-----------------------------------

local function moogleMagicCost(creature)
    return moogleMagicBase + moogleMagicStep * creature.magic
end

local function freeSlot(player)
    for slot = 1, xi.monsterRearing.maxCreatures(player) do
        if not readSlot(player, slot) then
            return slot
        end
    end

    return nil
end

--- Six bits per character across three CharVars, which is what fits retail's
--- fifteen-letter cap in integer-only player variables. 0 terminates.
-- 63 characters, so a 1-based code still fits the six bits. Anything outside
-- the set stores as a space rather than truncating the name.
local nameAlphabet = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
local nameCharsPerVar = 5
local nameVars = 3

-- Code 0 terminates, so the alphabet is 1-based: space is 1, not 0.
local nameCode = {}
for i = 1, #nameAlphabet do
    nameCode[string.sub(nameAlphabet, i, i)] = i
end

--- The name the player gave this creature, or its species if it has none.
---@param player CBaseEntity
---@param creature table
---@return string
xi.monsterRearing.creatureName = function(player, creature)
    local out = {}
    for v = 1, nameVars do
        local packed = player:getCharVar(slotVar(creature.slot, 'Nm' .. v))
        for c = 0, nameCharsPerVar - 1 do
            local code = bit.band(bit.rshift(packed, c * 6), 0x3F)
            if code > 0 then
                out[#out + 1] = string.sub(nameAlphabet, code, code)
            end
        end
    end

    local name = table.concat(out)
    if name == '' then
        return creature.form.name
    end

    return name
end

--- Store a name the client's naming widget handed back.
---@param player CBaseEntity
---@param slot integer
---@param name string
---@return nil
xi.monsterRearing.setCreatureName = function(player, slot, name)
    name = string.sub(name or '', 1, nameCharsPerVar * nameVars)

    for v = 1, nameVars do
        local packed = 0
        for c = 0, nameCharsPerVar - 1 do
            local index = (v - 1) * nameCharsPerVar + c + 1
            local ch    = string.sub(name, index, index)
            local code  = ch == '' and 0 or (nameCode[ch] or 1)
            packed = packed + bit.lshift(code, c * 6)
        end

        player:setCharVar(slotVar(slot, 'Nm' .. v), packed)
    end
end

--- Place a family's baby form in the first free slot.
---@param player CBaseEntity
---@param familyId integer
---@param respectDaily boolean
---@return boolean placed
local function placeCreature(player, familyId, respectDaily)
    local family = xi.monsterRearing.families[familyId]
    local slot   = freeSlot(player)
    if
        not family or
        not slot
    then
        return false
    end

    local today = earthDay()
    if
        respectDaily and
        player:getCharVar(newDayVar) >= today
    then
        return false
    end

    if respectDaily then
        player:setCharVar(newDayVar, today)
    end

    local creature =
    {
        slot    = slot,
        formId  = family.baby,
        form    = xi.monsterRearing.forms[family.baby],
        growth  = 0,
        mood    = 2,
        style   = 1,
        magic   = 0,
        pending = 0,
        tick    = today,
        actDay  = 0,
        actBits = 0,
    }

    writeSlot(player, creature)
    xi.monsterRearing.setCreatureName(player, slot, '')

    if player:getCharVar(focusVar) == 0 then
        player:setCharVar(focusVar, slot)
    end

    -- 8666
    say(player, string.format('%s has entered your %s!', creature.form.name,
        xi.monsterRearing.hasRearingGrounds(player) and 'rearing ground' or 'Mog Garden'))

    return true
end

--- Chacharoon's "Raise a new creature." Retail allows one a day.
local function takeCreature(player, familyId)
    if placeCreature(player, familyId, true) then
        return
    end

    if freeSlot(player) then
        -- 8741
        chacha(player, 'No neeew beasties be waiting around for you now. Come back and have pick of litter later.')
    else
        -- 8664
        chacha(player, 'Chacharoon no miiiracle worker! Can only do so much...')
    end
end

--- Put a family's baby form in the first free slot, ignoring the once-a-day
--- limit. Release the Fleece uses this to hand over the starting lamb.
---@param player CBaseEntity
---@param familyId integer
---@return boolean placed
xi.monsterRearing.grantCreature = function(player, familyId)
    return placeCreature(player, familyId, false)
end

-----------------------------------
-- The retail event layer
--
-- The client owns the whole menu tree. Firing csid 1075 (garden Chacharoon),
-- 1088 (rearing grounds) or 1076-1080 (a pen) hands the client its own bytecode,
-- which draws every window, walks every sub-menu and reports back. The server
-- only supplies the state the program reads, unblocks each yield with
-- updateEvent, and performs the action the client asks for. This is the same
-- shape eschan_hub.lua uses for Affi's vorseal shop and chocobo_raising.lua uses
-- for the VCS trainer.
--
-- WHAT THE PROGRAM READS, DECODED FROM OUR OWN CLIENT DAT DUMPS
--
-- The client maps startEvent num[i] onto WkZone[i+2] (live-calibrated in
-- eschan_hub.lua). Chacharoon's routine opens by loading three of them:
--
--     WkLocal[11] = WkZone[2] = num[0]     the packed state word
--     WkLocal[22] = WkZone[3] = num[1]
--     WkLocal[23] = WkZone[4] = num[2]
--
-- then slices num[0] into fields with opcode 0x41 (bit-range extract), the
-- ranges given as data[] constants:
--
--     bits  8-11 -> WkLocal[13]   (data[32]=8,  data[33]=11)
--     bits 12-15 -> WkLocal[12]   (data[34]=12, data[35]=15)
--     bits 16-19 -> WkLocal[14]   (data[36]=16, data[8]=19)
--     bits 21-23 -> WkLocal[25]   (data[37]=21, data[38]=23)
--     bits 24-25 -> WkLocal[26]   (data[39]=24, data[40]=25)
--
-- The top menu's option bitmask is WkLocal[10], which the program builds a bit
-- at a time with opcode 0x3C / 0x3D, one write per row, and the bit indices it
-- uses are data[29]=1, data[30]=2, data[31]=3, data[44]=4, data[43]=5,
-- data[47]=6, data[45]=7. Those are exactly rows 1 through 7 of dialog 8603,
-- which independently confirms the row order read off the Selection Dialog text.
-- The runs are gated on `WkLocal[14] < 3`, and rank 3 is precisely when retail
-- opens the rearing grounds and the second creature, so bits 16-19 of num[0] are
-- the Monster Rearing rank.
--
-- Every other menu in both programs takes a hard-coded mask of zero
-- (Chacharoon's data[7], the pens' data[5]), and zero is "disable nothing": the
-- yes/no confirmations and the rank 2-7 species lists all use it. So those
-- windows need no parameter at all and cannot be blanked by a wrong one.
--
-- WHAT IS NOT DECODED, AND WHY IT IS STILL SAFE TO SHIP
--
-- The exact bit layout the client reports a selection in. eschan_hub.lua proved
-- `row << 8` live for the same client's list widgets, with sub-menu picks
-- arriving as (extra << 16) | (row << 8) | action, and that is what is decoded
-- here. It cannot be settled from the bridge: menus never reach the chat log,
-- `answer` injects an outgoing 0x05B without advancing the client's own program,
-- and the puppet has no screenshot hook. So every selection is validated against
-- what the player is actually entitled to before anything happens, exactly as
-- eschan_hub's resolvePurchase does. A mis-decode browses; it never mis-acts.
-- Every option the client sends is logged so one session at a real screen pins
-- whatever is left.
-----------------------------------

-- Rows of dialog 8603, "Please make a decision." Order is the Selection Dialog
-- text's, confirmed against the bitmask bit indices the program writes.
local chacharoonRow =
{
    NOTHING   = 0,
    NEW       = 1,
    PARENTING = 2,
    PART      = 3,
    PRIORITY  = 4,
    ADVICE    = 5,
    CHEER     = 6,
    TRAVEL    = 7,
}

-- Rows of dialog 8703 / 8704, the pen care menu. 8704 is the same list with
-- "Change focus." inserted before "Collect items.", which is what the client
-- draws once more than one creature is being kept.
local penRow =
{
    NOTHING  = 0,
    CHECK    = 1,
    INTERACT = 2,
    NAME     = 3,
    COLLECT  = 4,
}

local penRowMulti =
{
    NOTHING  = 0,
    CHECK    = 1,
    INTERACT = 2,
    NAME     = 3,
    FOCUS    = 4,
    COLLECT  = 5,
}

-- Rows of dialog 8718, "How will you interact?"
local interactRow =
{
    [1] = xi.monsterRearing.interaction.PET,
    [2] = xi.monsterRearing.interaction.POKE,
    [3] = xi.monsterRearing.interaction.SLAP,
    [4] = xi.monsterRearing.interaction.YELL,
    [5] = xi.monsterRearing.interaction.ANGRY,
}

-- Rows of dialog 8670, "Place emphasis on what?"
local styleRow =
{
    [1] = 1, -- Personal growth.
    [2] = 2, -- Enjoying the moment.
}

local eventCsid =
{
    [17924231] = 1075, -- Chacharoon, main garden
    [17924232] = 1088, -- Chacharoon, rearing grounds
    [17924233] = 1076, -- the pen that shows the rearing priority
    [17924237] = 1080, -- rearing grounds pen, slot 1
    [17924234] = 1077, -- rearing grounds pen, slot 2
    [17924235] = 1078, -- rearing grounds pen, slot 3
    [17924236] = 1079, -- rearing grounds pen, slot 4
}

xi.monsterRearing.eventCsid = eventCsid

--- Split a reported selection the way eschan_hub proved this client reports its
--- list widgets: the low byte is the action, the next the row, the next any
--- quantity or sub-index.
---@param option integer
---@return integer row
---@return integer action
---@return integer extra
local function decodeOption(option)
    return bit.band(bit.rshift(option, 8), 0xFF),
        bit.band(option, 0xFF),
        bit.band(bit.rshift(option, 16), 0xFF)
end

--- The row a top-level pick refers to. Some windows report the row in the low
--- byte instead of the second, which is what a bare `row` looks like, so accept
--- both and let the caller's eligibility check reject a wrong reading.
---@param option integer
---@return integer
local function topRow(option)
    local row, action = decodeOption(option)
    if row == 0 and action <= 15 then
        return action
    end

    return row
end

--- Pack the state word the program slices out of num[0].
---@param player CBaseEntity
---@return integer
local function stateWord(player)
    local rank  = xi.monsterRearing.rank(player)
    local kept  = #xi.monsterRearing.creatures(player)
    local free  = xi.monsterRearing.maxCreatures(player) - kept
    local cheer = player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CHACHAROONS_CHEER) == xi.questStatus.QUEST_COMPLETED and 1 or 0

    -- bits 8-11 kept, 12-15 free slots, 16-19 rank, 21-23 cheer unlocked,
    -- 24-25 spare. Only the rank field is proven to drive anything; the others
    -- are filled with the state they most plainly name so the client has
    -- something truthful to render.
    return bit.lshift(kept, 8) +
        bit.lshift(free, 12) +
        bit.lshift(rank, 16) +
        bit.lshift(cheer, 21)
end

local navVar = 'MonsterRearingNav'
local slotVarLocal = 'MonsterRearingSlot'
local actedVar = 'MonsterRearingActed'

--- True the first time an option is seen in the current window.
--- A multi-window event yields once per menu, so a pick arrives in
--- onEventUpdate and the event stays open; only the last one, if any, reaches
--- onEventFinish. eschan_hub.lua does its work in update for exactly this
--- reason. Both callbacks dispatch here, and this guard is what stops the same
--- pick being acted on twice when it shows up in both. It matters most for the
--- two actions that spend shining stars.
---@param player CBaseEntity
---@param option integer
---@return boolean
local function claimOption(player, option)
    if player:getLocalVar(actedVar) == option then
        return false
    end

    player:setLocalVar(actedVar, option)
    return true
end

-----------------------------------
-- Chacharoon
-----------------------------------

--- Chacharoon was spoken to, in either the garden or the Rearing Grounds.
---@param player CBaseEntity
---@param npc CBaseEntity
---@return nil
xi.monsterRearing.chacharoonOnTrigger = function(player, npc)
    local csid = eventCsid[npc:getID()]
    if not csid then
        return
    end

    player:setLocalVar(navVar, 0)
    player:setLocalVar(actedVar, 0)
    player:startEvent(csid, stateWord(player), stars(player), xi.monsterRearing.careCount(player), 0, 0, 0, 0, 0)
end

--- Mid-event yields. Never terminate here: the client keeps the window open and
--- walks its own tree, and a missing answer freezes it.
---@param player CBaseEntity
---@param csid integer
---@param option integer
---@return nil
xi.monsterRearing.chacharoonOnEventUpdate = function(player, csid, option)
    if
        csid ~= 1075 and
        csid ~= 1088
    then
        return
    end

    print(string.format('[monsterRearing] %s chacharoon update csid %d option 0x%X', player:getName(), csid, option))

    xi.monsterRearing.chacharoonAct(player, option)

    -- Never terminate here. The client keeps the window open and walks its own
    -- tree; a missing answer freezes it.
    player:updateEvent(stateWord(player), stars(player), xi.monsterRearing.careCount(player), 0, 0, 0, 0, 0)
end

--- The window closed. Whatever the client reports is checked against what the
--- player may actually do before anything happens.
---@param player CBaseEntity
---@param csid integer
---@param option integer
---@return nil
xi.monsterRearing.chacharoonOnEventFinish = function(player, csid, option)
    if
        csid ~= 1075 and
        csid ~= 1088
    then
        return
    end

    print(string.format('[monsterRearing] %s chacharoon finish csid %d option 0x%X', player:getName(), csid, option))

    xi.monsterRearing.chacharoonAct(player, option)
    player:setLocalVar(actedVar, 0)
end

--- Act on one reported selection, from either callback.
---@param player CBaseEntity
---@param option integer
---@return nil
function xi.monsterRearing.chacharoonAct(player, option)
    if
        option == 0 or
        not claimOption(player, option)
    then
        return
    end

    local row, _, extra = decodeOption(option)
    local pick = topRow(option)

    if xi.monsterRearing.chacharoonCreatureRow(player, pick, row, extra) then
        return
    end

    xi.monsterRearing.chacharoonServiceRow(player, pick, row, extra)
end

--- The rows that act on a creature: raise, parenting style, part ways.
---@return boolean handled
function xi.monsterRearing.chacharoonCreatureRow(player, pick, row, extra)
    if pick == chacharoonRow.NEW then
        -- The species list is a sub-menu, so the family arrives in the same
        -- report. Refuse anything above the player's rank or with no slot free.
        local familyId = extra ~= 0 and extra or row
        local family   = xi.monsterRearing.families[familyId]
        if
            family and
            family.rank <= xi.monsterRearing.rank(player)
        then
            takeCreature(player, familyId)
        else
            -- 8741
            chacha(player, 'No neeew beasties be waiting around for you now. Come back and have pick of litter later.')
        end
    elseif pick == chacharoonRow.PARENTING then
        local creature = xi.monsterRearing.focused(player)
        local emphasis = styleRow[extra] or styleRow[row]
        if creature and emphasis then
            creature.style = emphasis
            writeSlot(player, creature)
            -- 8671 / 8672
            chacha(player, emphasis == 1 and
                '"Personal growth"? Yaaaaaay! That mean Chacharoon do much play with beastie so it get strong.' or
                '"Enjoy moment"? Then maybe making bed is best. Beastie be snuuug as bug in rug!')
        end
    elseif pick == chacharoonRow.PART then
        local creature = xi.monsterRearing.focused(player)
        if creature then
            -- 8674 row 1 send home, row 2 put down.
            if extra == 2 then
                putDown(player, creature)
            elseif extra == 1 then
                sendHome(player, creature)
            end
        end
    else
        return false
    end

    return true
end

--- The rows that act on the player: priority, cheer, travel.
---@return nil
function xi.monsterRearing.chacharoonServiceRow(player, pick, row, extra)
    if pick == chacharoonRow.PRIORITY then
        if xi.monsterRearing.maxCreatures(player) > 1 then
            local creature = readSlot(player, extra ~= 0 and extra or row)
            if creature then
                player:setCharVar(focusVar, creature.slot)
                -- 8605
                chacha(player, string.format('%s? Is bestest choice!', creature.form.name))
            end
        end
    elseif pick == chacharoonRow.CHEER then
        if player:getQuestStatus(xi.questLog.OTHER_AREAS, xi.quest.id.otherAreas.CHACHAROONS_CHEER) ~= xi.questStatus.QUEST_COMPLETED then
            return
        end

        -- The picker reports the memento's slot in the rank list it was chosen
        -- from. Only a memento the player actually holds is accepted.
        local wanted = nil
        for formId, form in pairs(xi.monsterRearing.forms) do
            if
                player:hasKeyItem(formId) and
                form.family == extra
            then
                wanted = form
                break
            end
        end

        if not wanted then
            return
        end

        if
            player:getCharVar(cheerVar) ~= 0 and
            not spendStars(player, cheerChangeCost)
        then
            return
        end

        setCheer(player, wanted.cheer)
        -- 8610
        say(player, string.format('Today\'s happy cheer is %s!', wanted.name))
    elseif pick == chacharoonRow.TRAVEL then
        if not xi.monsterRearing.hasRearingGrounds(player) then
            return
        end

        local inRearing = player:getZPos() < -400
        local target    = inRearing and travel.garden or travel.rearing
        player:setPos(target.x, target.y, target.z, target.rot)
    end
end

-----------------------------------
-- Rearing pens
-----------------------------------

local function penCreature(player, penId)
    if penId == xi.monsterRearing.npc.PEN_PRIORITY then
        return xi.monsterRearing.focused(player)
    end

    local slot = slotByPen[penId]
    if not slot then
        return nil
    end

    return readSlot(player, slot)
end

--- Pack the state word the pen program reads. Its care menu mask is WkLocal[15]
--- and the program writes only bits 2 and 3 of it, which are "Interact with the
--- beast" and "Give the creature a name"; every other window in that program
--- takes the hard-coded zero mask.
---@param creature table
---@return integer
local function penStateWord(creature)
    return bit.lshift(starsOf(creature), 8) +
        bit.lshift(creature.mood, 12) +
        bit.lshift(creature.form.family, 16)
end

--- A rearing pen was examined.
---@param player CBaseEntity
---@param npc CBaseEntity
---@return nil
xi.monsterRearing.penOnTrigger = function(player, npc)
    local penId = npc:getID()
    local csid  = eventCsid[penId]
    if
        not csid or
        penId == xi.monsterRearing.npc.CHACHAROON_GARDEN or
        penId == xi.monsterRearing.npc.CHACHAROON_REARING
    then
        return
    end

    local creature = penCreature(player, penId)
    if not creature then
        player:messageSpecial(zones[xi.zone.MOG_GARDEN].text.NOTHING_OUT_OF_ORDINARY)
        return
    end

    player:setLocalVar(slotVarLocal, creature.slot)
    player:setLocalVar(actedVar, 0)

    -- The creature's name goes in the string slots the client renders as
    -- "Player/Chocobo Parameter 0"; chocobo_raising.lua feeds its chocobo the
    -- same way. Until a creature is named it answers to its species.
    local name = xi.monsterRearing.creatureName(player, creature)
    player:startEventString(csid, name, name, name, name,
        penStateWord(creature), stars(player), creature.growth, creature.mood, 0, 0, 0, 0)
end

xi.monsterRearing.penOnEventUpdate = function(player, csid, option)
    local slot = player:getLocalVar(slotVarLocal)
    local creature = slot > 0 and readSlot(player, slot) or nil
    if not creature then
        return
    end

    print(string.format('[monsterRearing] %s pen update csid %d option 0x%X', player:getName(), csid, option))

    xi.monsterRearing.penAct(player, creature, option)

    creature = readSlot(player, slot) or creature
    player:updateEvent(penStateWord(creature), stars(player), creature.growth, creature.mood, 0, 0, 0, 0)
end

xi.monsterRearing.penOnEventFinish = function(player, csid, option)
    local slot = player:getLocalVar(slotVarLocal)
    player:setLocalVar(slotVarLocal, 0)

    local creature = slot > 0 and readSlot(player, slot) or nil
    if not creature then
        return
    end

    print(string.format('[monsterRearing] %s pen finish csid %d option 0x%X', player:getName(), csid, option))

    xi.monsterRearing.penAct(player, creature, option)
    player:setLocalVar(actedVar, 0)
end

--- Act on one reported pen selection, from either callback.
---@param player CBaseEntity
---@param creature table
---@param option integer
---@return nil
function xi.monsterRearing.penAct(player, creature, option)
    if
        option == 0 or
        not claimOption(player, option)
    then
        return
    end

    -- The darkness window replaces the care menu entirely, so its rows are
    -- decoded first: 8732 row 1 moogle magic, row 2 put the creature down.
    if creature.mood == 0 then
        local pick = topRow(option)
        if pick == 1 then
            if spendStars(player, moogleMagicCost(creature)) then
                creature.mood  = 2
                creature.magic = creature.magic + 1
                writeSlot(player, creature)
                -- 8736
                say(player, string.format('The darkness no longer dwells within %s\'s heart.', creature.form.name))
            end
        elseif pick == 2 then
            putDown(player, creature)
        end

        return
    end

    local multi = #xi.monsterRearing.creatures(player) > 1
    local rows  = multi and penRowMulti or penRow
    local pick  = topRow(option)
    local _, _, extra = decodeOption(option)

    if pick == rows.CHECK then
        describe(player, creature)
    elseif pick == rows.INTERACT then
        local action = interactRow[extra]
        if action then
            doInteract(player, creature, action)
        end
    elseif pick == rows.NAME then
        -- The name itself arrives as an event string, not in the option, so
        -- onEventUpdateString is where it is taken.
        return
    elseif pick == rows.FOCUS then
        player:setCharVar(focusVar, creature.slot)
        -- 8705
        say(player, string.format('You have decided to focus on rearing %s.', creature.form.name))
    elseif pick == rows.COLLECT then
        doCollect(player, creature)
    end
end

--- Food traded to a rearing pen. Retail feeds a creature by handing it the
--- food, which is why Feeding Frenzy reads "Feed (trade) the sheep the La Theine
--- Cabbage".
---@param player CBaseEntity
---@param npc CBaseEntity
---@param trade CTradeContainer
---@return nil
xi.monsterRearing.penOnTrade = function(player, npc, trade)
    local creature = penCreature(player, npc:getID())
    if not creature then
        return
    end

    local itemId = trade:getItemId()
    if
        trade:getItemCount() ~= 1 or
        not xi.monsterRearing.foodGroup[itemId]
    then
        return
    end

    player:confirmTrade()
    doFeed(player, creature, itemId)
end

--- The client's naming widget hands the typed name back as an event string.
---@param player CBaseEntity
---@param updateString string
---@return nil
xi.monsterRearing.penOnEventUpdateString = function(player, updateString)
    local slot = player:getLocalVar(slotVarLocal)
    if slot < 1 then
        return
    end

    xi.monsterRearing.setCreatureName(player, slot, updateString)
end

return xi.monsterRearing
