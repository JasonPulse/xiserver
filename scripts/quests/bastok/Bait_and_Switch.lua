-----------------------------------
-- Bait and Switch
-----------------------------------
-- Log ID: 1, Quest ID: 83
-- Salim : Metalworks (G-7)
-- ???   : Temple of the Goddess, ground floor (G-8), via the elevator
--
-- NOTE ON ZONES: the Temple of the Goddess is an alcove INSIDE Metalworks, not a
-- separate zone -- zone 237 dialog 7533 is "This alcove is our Temple of the
-- Goddess." qm4 is entity 17748159, which decodes to zone 237 index 575, so the
-- ???, Salim and all three switches live in xi.zone.METALWORKS.
-----------------------------------
-- Retail (bg-wiki "Bait and Switch"), repeatable once per Conquest Tally:
--   1. Speak to Salim to start. Fame Bastok 3.
--   2. Examine the ??? on the ground floor of the Temple of the Goddess (G-8).
--   3. Pick one of 7 aid items. The pick sets both how many switch activations
--      the sequence runs to and which reward you get:
--        Scope                3   Silent Oil
--        Bard's harp          4   Prism Powder
--        Lead Guardsman's ID  6   Hi-Potion
--        Snares               8   Hi-Ether
--        Lucky charm          8   Key Ring Belt
--        Pocket watch         8   Hermes Quencher
--        Costume kit         10   Icarus Wing
--      Costume kit only unlocks after clearing each of the first six AND after
--      Chameleon Capers is complete.
--   4. Interrogate the clue NPCs -- Folzen gives the count; Darha, Helmut,
--      Hungry Wolf and Striking Snake give the order.
--   5. Activate the switches in that order. Wrong switch -> start over.
--   6. Return to the ??? for a cutscene and the reward.
--
-- CSIDs decoded, not guessed. Salim is entity 17747999 (npc_list:28583);
-- (17747999-16777216) = 970783, 970783//4096 = 237 rem 31 -> Metalworks,
-- 0x010ED01F. Read against `xi-dat dialog 237`:
--   400 -> 7507 "I must raise the Metalworks output before my term here ends."
--          -- his idle line, an 11-byte program directly on him
--   899 -> the offer. `xi-dat csid 237 899` shows a 492-byte program on the
--          zone-global 0x7FFFFFF0 plus 1-byte stubs on Salim and 0x010ED020.
--          Its data table holds 10174-10183, and 10179 is "Lately, there's been
--          an unusual friar idling around the Temple of the Goddess..." --
--          verbatim the bg-wiki quest Description, which is what pins it.
--   900 -> the ??? reveal and the 7-item picker. Owner is 'blank' 0x010ED0C4
--          (17748164, npc_list:28748), 4541 bytes, with 1-byte stubs on Salim,
--          on qm4/??? 0x010ED0BF (17748159, npc_list:28743) and 8 other actors.
--          csidmsg 237 17748164 -> 900 -> 10214 "Choose your weapon!
--          ${selection-lines}", with context 10195 "Hee hee. Surprised? Anyway,
--          it was Salim who told you to come here, wasn't it?", 10198
--          "Miledo-Shiraddo is disguised as a friar", 10202 "There must be a
--          switch or two somewhere to deactivate it", 10212 "I've brought seven
--          helpful little goodies along with me".
--   907 -> a 47-byte program on qm4 itself -> 10249-10251, the ??? follow-up.
--
-- Every minigame NPC exists in npc_list, and their coordinates corroborate
-- bg-wiki's locations exactly:
--   Small_Switch  17748160 (-57.584, 1.740, 21.920) -- beside
--                 _6l3 'Door:Cermet Refinery' 17748044 (-61.692, 0.381, 22.307)
--   Medium_Switch 17748161 (-31.176, -1.000, 0.043) -- beside
--                 Quasim 17748062 (-30.085, 0.000, 1.464), i.e. the Replica
--   Large_Switch  17748162 (-93.831, 0.953, 0.072) -- the kiln
--   Clues: Folzen 17748003, Darha 17748029, Helmut 17748002,
--          Hungry_Wolf 17748007, Striking_Snake 17747979
--   Alerts: Gentle_Tiger 17748146, Militant_Gale 17748147,
--           Pensive_Beast 17748149 (all status 2, spawned on demand)
--
-- CRITICAL FAUCET REMOVED: the previous stub's `check` accepted QUEST_COMPLETED
-- and its onEventFinish[401] did addQuest -> addItem -> completeQuest in a single
-- Salim click, with no minigame and no tally gate. That was unlimited Pots of
-- Silent Oil from one repeated click. csids 401/402 are real programs in
-- Metalworks but belong to 0x010ED020 and 0x010ED021, not to this quest; nothing
-- fires them, and they are not touched here.
--
-- bg-wiki lists no fame for this quest, so the stub's 30 is gone.
--
-- STILL SIMPLIFIED, and deliberately not faked: the clue NPCs and the four alert
-- NPCs are not wired. Their programs are the three 20KB blobs on 'blank'
-- 0x010ED0C3 (17748163) -- csids 908/909/910, 21032 / 20100 / 22112 bytes with
-- ~18 actor stubs each -- and attributing individual csids inside those needs
-- param-level work that is not done. So the switch order is not yet discoverable
-- in-game and has to be brute-forced. That is safe rather than exploitable
-- because the Conquest Tally gate below is enforced, so the ceiling is one
-- reward per tally either way, exactly as retail. The reward paid is the correct
-- one for the item picked.
-----------------------------------
local metalworksID = zones[xi.zone.METALWORKS]

local quest = Quest:new(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)

-- Indexed by the option returned from csid 900's "Choose your weapon!" picker.
-- switches = how many activations the sequence runs to; reward = bg-wiki's table.
local aidItems =
{
    { name = 'Scope',               switches =  3, reward = xi.item.POT_OF_SILENT_OIL     },
    { name = "Bard's harp",         switches =  4, reward = xi.item.PINCH_OF_PRISM_POWDER },
    { name = "Lead Guardsman's ID", switches =  6, reward = xi.item.HI_POTION             },
    { name = 'Snares',              switches =  8, reward = xi.item.HI_ETHER              },
    { name = 'Lucky charm',         switches =  8, reward = xi.item.KEY_RING_BELT         },
    { name = 'Pocket watch',        switches =  8, reward = xi.item.HERMES_QUENCHER       },
    { name = 'Costume kit',         switches = 10, reward = xi.item.ICARUS_WING           },
}

local costumeKitPick = 7

-- The three physical switches. A sequence is a string of these indices.
local switches =
{
    ['Small_Switch']  = 1,
    ['Medium_Switch'] = 2,
    ['Large_Switch']  = 3,
}

-- bg-wiki: Costume kit "is only available after clearing each of the first six
-- items and the quest Chameleon Capers is cleared."
--
-- THE CHAMELEON CAPERS PREREQUISITE IS DELIBERATELY DROPPED ON THIS SERVER.
-- Chameleon Capers is an Adventuring Fellow quest, and the whole fellow line has
-- been removed here (we use trusts instead), so that quest can no longer be
-- completed by anyone. Leaving the check in place would have made the Costume kit
-- -- the seventh and last reward of THIS quest, which has nothing to do with
-- fellows -- permanently unobtainable as a side effect of dropping an unrelated
-- chain. The six-item requirement below is retail and is kept.
local function costumeKitUnlocked(player)
    local cleared = player:getCharVar('BaitAndSwitchItemsCleared')

    for pick = 1, #aidItems - 1 do
        if not utils.mask.getBit(cleared, pick - 1) then
            return false
        end
    end

    return true
end

-- The order is randomised per run. Stored as one digit per activation so the
-- whole sequence survives in a single quest var.
local function rollSequence(player, count)
    local sequence = 0

    for _ = 1, count do
        sequence = (sequence * 10) + math.random(1, 3)
    end

    quest:setVar(player, 'Sequence', sequence)
    quest:setVar(player, 'Pressed', 0)
end

local function expectedAt(sequence, count, position)
    -- Digits are most-significant-first, so peel from the left.
    local divisor = 10 ^ (count - position)

    return math.floor(sequence / divisor) % 10
end

quest.sections =
{
    -- Salim offers the job. Repeatable, but only once per Conquest Tally.
    {
        check = function(player, status, vars)
            return (status == xi.questStatus.QUEST_AVAILABLE or status == xi.questStatus.QUEST_COMPLETED) and
                player:getFameLevel(xi.fameArea.BASTOK) >= 3 and
                player:getCharVar('BaitAndSwitchTally') == 0
        end,

        [xi.zone.METALWORKS] =
        {
            ['Salim'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(899)
                end,
            },

            onEventFinish =
            {
                [899] = function(player, csid, option, npc)
                    if option ~= 0 then
                        return
                    end

                    if player:getQuestStatus(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH) == xi.questStatus.QUEST_COMPLETED then
                        player:addQuest(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)
                    else
                        quest:begin(player)
                    end

                    quest:setVar(player, 'Pick', 0)
                    quest:setVar(player, 'Sequence', 0)
                    quest:setVar(player, 'Pressed', 0)
                end,
            },
        },
    },

    -- Accepted, no aid item picked yet: the ??? in the Temple of the Goddess.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Pick == 0
        end,

        [xi.zone.METALWORKS] =
        {
            ['Salim'] = quest:event(400),

            ['qm4'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(900, { [0] = costumeKitUnlocked(player) and 1 or 0 })
                end,
            },

            onEventFinish =
            {
                [900] = function(player, csid, option, npc)
                    local pick = option

                    if pick < 1 or pick > #aidItems then
                        return
                    end

                    if pick == costumeKitPick and not costumeKitUnlocked(player) then
                        return
                    end

                    quest:setVar(player, 'Pick', pick)
                    rollSequence(player, aidItems[pick].switches)
                end,
            },
        },
    },

    -- The switch run.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Pick ~= 0 and
                vars.Pressed < aidItems[vars.Pick].switches
        end,

        [xi.zone.METALWORKS] =
        {
            ['Salim'] = quest:event(400),
        },
    },

    -- Sequence complete: back to the ??? for the reward.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Pick ~= 0 and
                vars.Pressed >= aidItems[vars.Pick].switches
        end,

        [xi.zone.METALWORKS] =
        {
            ['qm4'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(907, { [0] = aidItems[quest:getVar(player, 'Pick')].reward })
                end,
            },

            onEventFinish =
            {
                [907] = function(player, csid, option, npc)
                    local pick = quest:getVar(player, 'Pick')
                    local item = aidItems[pick].reward

                    if not npcUtil.giveItem(player, item) then
                        return
                    end

                    -- Track which aid items have been cleared: Costume kit only
                    -- unlocks once all six others have been used successfully.
                    player:setCharVar('BaitAndSwitchItemsCleared',
                        utils.mask.setBit(player:getCharVar('BaitAndSwitchItemsCleared'), pick - 1, true))

                    player:setCharVar('BaitAndSwitchTally', 1, NextConquestTally())
                    player:completeQuest(xi.questLog.BASTOK, xi.quest.id.bastok.BAIT_AND_SWITCH)

                    quest:setVar(player, 'Pick', 0)
                    quest:setVar(player, 'Sequence', 0)
                    quest:setVar(player, 'Pressed', 0)
                end,
            },
        },
    },
}

-- The three switches behave identically, so register them from the table. A
-- correct press advances; a wrong one restarts the run, which is what bg-wiki's
-- "you will have to start from the beginning" means.
local runSection = quest.sections[3]

for npcName, switchIndex in pairs(switches) do
    runSection[xi.zone.METALWORKS][npcName] =
    {
        onTrigger = function(player, npc)
            local pick     = quest:getVar(player, 'Pick')
            local count    = aidItems[pick].switches
            local pressed  = quest:getVar(player, 'Pressed')
            local sequence = quest:getVar(player, 'Sequence')

            -- Wrong switch: bg-wiki says you start from the beginning. Retail
            -- also spawns one of the four alert NPCs here, which is the part not
            -- yet wired, so the reset is silent rather than given a message id
            -- that does not exist for it.
            if switchIndex ~= expectedAt(sequence, count, pressed + 1) then
                rollSequence(player, count)

                return quest:noAction()
            end

            pressed = pressed + 1
            quest:setVar(player, 'Pressed', pressed)

            -- 10632-10640 are "The first/.../ninth switch has been deactivated",
            -- and 10641 is the final "You hear a noise from the direction of the
            -- Temple of the Goddess." A 10-switch run therefore uses all nine
            -- ordinals plus the noise, which is exactly why the block stops at
            -- ninth.
            if pressed >= count then
                return quest:messageSpecial(metalworksID.text.NOISE_FROM_TEMPLE)
            end

            return quest:messageSpecial(metalworksID.text.SWITCH_DEACTIVATED_OFFSET + pressed - 1)
        end,
    }
end

return quest
