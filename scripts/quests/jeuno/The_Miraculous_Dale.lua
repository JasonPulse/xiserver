-----------------------------------
-- The Miraculous Dale
-----------------------------------
-- Log ID: 3, Quest ID: 100
-- Rakuru-Rakoru : Lower Jeuno (I-6), next to the fountain
-----------------------------------
-- Retail (bg-wiki "The Miraculous Dale"): level 75+. Rakuru-Rakoru asks you to
-- defeat 16 Notorious Monsters while carrying the {KI} Data Analyzer and Logger
-- EX. Each kill records that NM's battle data. Speak to him at any time to check
-- progress; once all 16 are recorded, return for 59,630 gil.
--
-- Nyzul Isle variants do NOT count -- which is handled naturally here, because
-- the onMobDeath hooks are registered per overworld zone, so a same-named mob
-- inside Nyzul Isle never reaches these handlers.
--
-- Previously this was a stub that paid the full 59,630 gil for a single NPC
-- click, with no key item and no kills -- by a wide margin the largest gil leak
-- found in the jeuno audit.
--
-- TURN-IN CSID CORRECTED 10079 -> 10082. Rakuru-Rakoru is entity 17780928;
-- (17780928-16777216) = 1003712, 1003712//4096 = 245 rem 192 -> Lower Jeuno,
-- 0x010F50C0. `xi-dat events 245` gives him 10078-10083 and 10094, and csidscan
-- against `xi-dat dialog 245` splits them cleanly:
--   10078 -> 7063                his one-line hail
--   10079 -> 7064-7107           THE OFFER. 7066 "I'm Rakuru-Rakoru, soon-to-be
--            leading citizen of Windurst. I've got a proposal that you couldn't
--            possibly resistaru!", 7068 "What do you say? / Propose away! /
--            I'm too busy.", 7070 "Greataru! I knew you had promise!"
--   10080 -> 7087-7105           the 16-entry monster checklist
--   10081 -> 7086, 7108-7114     the progress check (wired below)
--   10082 -> 7115-7129           THE COMPLETION. 7115 "<Gasp!> The...the data.
--            It...it's finally complete!", 7116 "I knew a sorry bunch of
--            monstarus like that would be a cakewalk", 7118 "Now, let me prepare
--            your reward for services rendered..."
--   10083 -> 7063, 7129          the post-quest bookend
-- The turn-in was replaying 10079, the OFFER, so finishing all sixteen NMs
-- replayed the "I've got a proposal" pitch instead of the reward scene.
--
-- NEEDS AN IN-GAME PROBE -- the accept below tests `option == 1`, and that is NOT
-- verified. 10079 carries TWO prompts and the accepting line is listed FIRST in
-- both: 7068 "Propose away!" before "I'm too busy.", and 7070 "Reward? Count me
-- in!" before "Nah, it's not worth the effort." (7069 and 7083 are the two
-- decline replies.) By the ordering convention that would make accept option 0,
-- but how the event VM reports `option` for a two-prompt program is not something
-- the DAT alone settles, so it is left as found and flagged rather than flipped
-- on a guess -- changing it wrongly would break an accept that may work today.
-- Confirm with `!cs 10079` on Rakuru-Rakoru.
--
-- All 16 NMs and all 12 zones were confirmed present in this repo before wiring:
-- each name has spawn rows in sql/mob_spawn_points.sql and each zone constant
-- exists in scripts/enum/zone.lua.
-----------------------------------
local quest = Quest:new(xi.questLog.JEUNO, xi.quest.id.jeuno.THE_MIRACULOUS_DALE)

quest.reward =
{
    gil = 59630,
}

-- Bit index per NM, matching the bg-wiki table order. The bit is stored in the
-- quest var 'Data' so progress survives logout.
local targets =
{
    [xi.zone.LA_THEINE_PLATEAU]     = { Tumbling_Truffle   = 0 },
    [xi.zone.BATALLIA_DOWNS]        = { Tottering_Toby     = 1 },
    [xi.zone.DAVOI]                 = { Blubbery_Bulge     = 2 },
    [xi.zone.ROLANBERRY_FIELDS]     = { Black_Triple_Stars = 3, Drooling_Daisy = 4 },
    [xi.zone.PASHHOW_MARSHLANDS]    = { Jolly_Green        = 5 },
    [xi.zone.EAST_SARUTABARUTA]     = { ['Sharp-Eared_Ropipi'] = 6 },
    [xi.zone.BUBURIMU_PENINSULA]    = { Buburimboo         = 7 },
    [xi.zone.MERIPHATAUD_MOUNTAINS] = { Daggerclaw_Dracos  = 8 },
    [xi.zone.QUFIM_ISLAND]          = { Trickster_Kinetix  = 9 },
    [xi.zone.UPPER_DELKFUTTS_TOWER] = { Ixtab              = 10 },
    [xi.zone.BEAUCEDINE_GLACIER]    = { Gargantua          = 11 },
    [xi.zone.XARCABARD]             =
    {
        Shadow_Eye    = 12,
        Boreal_Coeurl = 13,
        Boreal_Hound  = 14,
        Boreal_Tiger  = 15,
    },
}

local allRecorded = 0xFFFF -- bits 0-15

local function recordKill(bitNum)
    return function(mob, player, optParams)
        if not player:hasKeyItem(xi.ki.DATA_ANALYZER_AND_LOGGER_EX) then
            return
        end

        local data = quest:getVar(player, 'Data')

        if utils.mask.getBit(data, bitNum) then
            return
        end

        quest:setVar(player, 'Data', utils.mask.setBit(data, bitNum, true))

        -- Retail also prints "The relevant battle data has been recorded in your
        -- Data Analyzer and Logger EX." That message id is not present in any
        -- zone's IDs.lua here, and messageSpecial ids live in a different
        -- numbering space than the event dialog table, so it is deliberately not
        -- guessed. Progress is still checkable by speaking to Rakuru-Rakoru,
        -- which is the retail behaviour anyway.
    end
end

-- Build one zone section entry per NM, keyed by mob name.
local function mobSection(zoneId)
    local section = {}

    for mobName, bitNum in pairs(targets[zoneId]) do
        section[mobName] = { onMobDeath = recordKill(bitNum) }
    end

    return section
end

local killSection =
{
    check = function(player, status, vars)
        return status == xi.questStatus.QUEST_ACCEPTED and
            player:hasKeyItem(xi.ki.DATA_ANALYZER_AND_LOGGER_EX)
    end,
}

for zoneId in pairs(targets) do
    killSection[zoneId] = mobSection(zoneId)
end

quest.sections =
{
    -- Offer: Rakuru-Rakoru hands over the Data Analyzer and Logger EX.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_AVAILABLE and
                player:getMainLvl() >= 75
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Rakuru-Rakoru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10079)
                end,
            },

            onEventFinish =
            {
                [10079] = function(player, csid, option, npc)
                    if option == 1 then
                        quest:begin(player)
                        npcUtil.giveKeyItem(player, xi.ki.DATA_ANALYZER_AND_LOGGER_EX)
                    end
                end,
            },
        },
    },

    killSection,

    -- Progress check. bg-wiki: "Speak with Rakuru-Rakoru at any time to check
    -- your progress." This section did not exist, so while the hunt was underway
    -- nothing bound Rakuru-Rakoru at all -- killSection only adds the NM zones --
    -- and he fell through to generic default dialog.
    -- 10081 is his progress program: dialog 7108 "Hey! How goes my promotion
    -- exam--uh...the collection of data?", 7109 "May I see the
    -- ${keyitem-singular: 0[2]}? ${selection-lines} Certainly. / Nothing to see
    -- here.", then the graduated replies 7110 "You still have a long way to go"
    -- and 7111 "Looks like you've made some progress." The one ${keyitem} slot is
    -- why param 0 is the logger.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Data ~= allRecorded
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Rakuru-Rakoru'] = quest:event(10081, { [0] = xi.ki.DATA_ANALYZER_AND_LOGGER_EX }),
        },
    },

    -- Turn-in: only once every one of the 16 data points is recorded.
    {
        check = function(player, status, vars)
            return status == xi.questStatus.QUEST_ACCEPTED and
                vars.Data == allRecorded
        end,

        [xi.zone.LOWER_JEUNO] =
        {
            ['Rakuru-Rakoru'] =
            {
                onTrigger = function(player, npc)
                    return quest:progressEvent(10082)
                end,
            },

            onEventFinish =
            {
                [10082] = function(player, csid, option, npc)
                    if quest:complete(player) then
                        player:delKeyItem(xi.ki.DATA_ANALYZER_AND_LOGGER_EX)
                        quest:setVar(player, 'Data', 0)
                    end
                end,
            },
        },
    },
}

return quest
