-----------------------------------
-- Kupofried's Weapon Skill Moogle Magic
--
-- Fourteen bg-wiki quests, one per weapon skill type, all driven by the same
-- ??? in the Walk of Echoes -- they are a single client menu, not fourteen
-- separate scripts:
--   Kupofried's H2H / Dagger / Sword / Great Sword / Axe / Great Axe / Scythe /
--   Polearm / Katana / Great Katana / Club / Staff / Archery / Marksmanship
--   Moogle Magic
--
-- None of the fourteen has a quest-log id (they are |Title= and |Repeatable=
-- empty on bg-wiki and never appear in the log), which is why this is an NPC
-- handler rather than Quest:new objects.
--
-- Retail (bg-wiki, identical text on all fourteen pages with the noun swapped):
--   |Quest Reqs=Guardian of the Void  |Level=90~99  |Fame=Other
--   1. Select the ??? in the Walk of Echoes.
--   2. Select the weapon type you wish to unlock.
--   3. Trade the ??? the required weapon for a short scene unlocking the skill.
--   Reward: "The ability to use <skill> with any <weapon type>."
--
-- CSIDS DECODED, NOT GUESSED. The ??? is `qm` 17523344 (zone 182, idx 656),
-- which shares its whole 118-122 block with Kupofried 17523343 -- that shared
-- ownership is what identifies it. Resolved with csidscan.py (csidmsg.py
-- returns nothing for several [S]/instanced zones):
--   118  msgs 8055-8081, the FIRST-TIME program: the explanation (8055-8062),
--        the accept prompt 8063 "Does it interest you? / Yes! Give me the
--        power! / Not at the moment.", then the type menu and confirmation.
--   120  msgs 8061, 8072-8080 -- the REPEAT visit, which skips the long
--        preamble and opens straight on 8074 "Designate thy desire, kupo."
--   122  msgs 8082-8087, the TRANSFERENCE: 8082/8083 inspect the weapon
--        ("worthy of the moniker 'Empyrean'"), 8084-8086 perform it, 8087
--        "prithee wield another weapon and watch what happens".
--   121  msg 8088, the "overexposure to moogle magic" caution.
--   119  msgs 8090/8091 "Continue or quit?".
--
-- THE TYPE -> SKILL MAPPING IS THE CLIENT\'S OWN, not an inference. Message
-- 8075 lists the selection lines in this order:
--   Hand-to-hand / Dagger / Sword / Great Sword / Axe / Great Axe / Scythe /
--   Polearm / Katana / Great Katana / Club / Staff / Archery / Marksmanship /
--   None for the nonce
-- and message 8089 announces the result with the SAME param 0 index:
--   [Victory Smite / Rudra\'s Storm / Chant du Cygne / Torcleaver /
--    Cloudsplitter / Ukko\'s Fury / Quietus / Camlann\'s Torment / Blade: Hi /
--    Tachi: Fudo / Dagan / Myrkr / Jishnu\'s Radiance / Wildfire]
-- Those fourteen names are exactly xi.wsUnlock 35..48 in order
-- (ws_unlock.lua:43-56), so menu option N is wsUnlock 35 + N. The table below
-- states each one explicitly rather than relying on that arithmetic.
--
-- REQUIRED WEAPONS come from each page\'s |Item Reqs=, which is always
-- "Must have either a <predecessor> or a level 90~99 <Empyrean>". The
-- predecessor ids and every Empyrean id at level 90+ were read out of
-- item_basic + item_equipment rather than typed in. Two traps this avoided:
-- Great Katana\'s predecessor is item_basic name `torigashiranotachi` (19903),
-- not `torigashira` (that is only its sort name); and the base Empyrean ids
-- (Almace 19399 etc.) are level 80, so they do NOT satisfy "level 90~99" and
-- are deliberately absent below.
-----------------------------------

xi = xi or {}
xi.kupofriedMoogleMagic = xi.kupofriedMoogleMagic or {}

-- Indexed to match message 8075\'s selection lines exactly; option 14 is
-- "None for the nonce" and falls through to no entry.
local weaponTypes =
{
    -- [0] Hand-to-hand
    {
        wsUnlock = xi.wsUnlock.VICTORY_SMITE,
        -- dumuzis (any level) or verethragna at level 90+
        items =
        {
            xi.item.DUMUZIS, -- dumuzis (lv99)
            20544, -- dumuzis_-1 (lv99)
            xi.item.VERETHRAGNA_90, -- verethragna_90 (lv90)
            xi.item.VERETHRAGNA_95, -- verethragna_95 (lv95)
            xi.item.VERETHRAGNA_99, -- verethragna_99 (lv99)
            xi.item.VERETHRAGNA_99_II, -- verethragna_99_ii (lv99)
            20486, -- verethragna_119 (lv99)
            20487, -- verethragna_119_ii (lv99)
            xi.item.VERETHRAGNA_119_III, -- verethragna_119_iii (lv99)
        },
    },
    -- [1] Dagger
    {
        wsUnlock = xi.wsUnlock.RUDRAS_STORM,
        -- khandroma (any level) or twashtar at level 90+
        items =
        {
            xi.item.KHANDORMA, -- khandroma (lv99)
            20631, -- khandroma_-1 (lv99)
            xi.item.TWASHTAR_90, -- twashtar_90 (lv90)
            xi.item.TWASHTAR_95, -- twashtar_95 (lv95)
            xi.item.TWASHTAR_99, -- twashtar_99 (lv99)
            xi.item.TWASHTAR_99_II, -- twashtar_99_ii (lv99)
            20563, -- twashtar (lv99)
            20564, -- twashtar (lv99)
            xi.item.TWASHTAR_119_III, -- twashtar (lv99)
        },
    },
    -- [2] Sword
    {
        wsUnlock = xi.wsUnlock.CHANT_DU_CYGNE,
        -- brunello (any level) or almace at level 90+
        items =
        {
            xi.item.BRUNELLO, -- brunello (lv99)
            20732, -- brunello_-1 (lv99)
            xi.item.ALMACE_90, -- almace_90 (lv90)
            xi.item.ALMACE_95, -- almace_95 (lv95)
            xi.item.ALMACE_99, -- almace_99 (lv99)
            xi.item.ALMACE_99_II, -- almace_99_ii (lv99)
            20653, -- almace (lv99)
            20654, -- almace (lv99)
            xi.item.ALMACE_119_III, -- almace (lv99)
        },
    },
    -- [3] Great Sword
    {
        wsUnlock = xi.wsUnlock.TORCLEAVER,
        -- xiphias (any level) or caladbolg at level 90+
        items =
        {
            xi.item.XIPHIAS, -- xiphias (lv99)
            20769, -- xiphias_-1 (lv99)
            xi.item.CALADBOLG_90, -- caladbolg_90 (lv90)
            xi.item.CALADBOLG_95, -- caladbolg_95 (lv95)
            xi.item.CALADBOLG_99, -- caladbolg_99 (lv99)
            xi.item.CALADBOLG_99_II, -- caladbolg_99_ii (lv99)
            20747, -- caladbolg (lv99)
            20748, -- caladbolg (lv99)
            xi.item.CALADBOLG_119_III, -- caladbolg (lv99)
        },
    },
    -- [4] Axe
    {
        wsUnlock = xi.wsUnlock.CLOUDSPLITTER,
        -- sacripante (any level) or farsha at level 90+
        items =
        {
            xi.item.SACRIPANTE, -- sacripante (lv99)
            20821, -- sacripante_-1 (lv99)
            xi.item.FARSHA_90, -- farsha_90 (lv90)
            xi.item.FARSHA_95, -- farsha_95 (lv95)
            xi.item.FARSHA_99, -- farsha_99 (lv99)
            xi.item.FARSHA_99_II, -- farsha_99_ii (lv99)
            20794, -- farsha (lv99)
            20795, -- farsha (lv99)
            xi.item.FARSHA_119_III, -- farsha (lv99)
        },
    },
    -- [5] Great Axe
    {
        wsUnlock = xi.wsUnlock.UKKOS_FURY,
        -- shamash (any level) or ukonvasara at level 90+
        items =
        {
            xi.item.SHAMASH, -- shamash (lv99)
            20867, -- shamash_-1 (lv99)
            xi.item.SHAMASH_ROBE, -- shamash_robe (lv99)
            xi.item.UKONVASARA_90, -- ukonvasara_90 (lv90)
            xi.item.UKONVASARA_95, -- ukonvasara_95 (lv95)
            xi.item.UKONVASARA_99, -- ukonvasara_99 (lv99)
            xi.item.UKONVASARA_99_II, -- ukonvasara_99_ii (lv99)
            20839, -- ukonvasara (lv99)
            20840, -- ukonvasara (lv99)
            xi.item.UKONVASARA_119_III, -- ukonvasara (lv99)
        },
    },
    -- [6] Scythe
    {
        wsUnlock = xi.wsUnlock.QUIETUS,
        -- umiliati (any level) or redemption at level 90+
        items =
        {
            xi.item.UMILIATI, -- umiliati (lv99)
            20912, -- umiliati_-1 (lv99)
            xi.item.REDEMPTION_90, -- redemption_90 (lv90)
            xi.item.REDEMPTION_95, -- redemption_95 (lv95)
            xi.item.REDEMPTION_99, -- redemption_99 (lv99)
            xi.item.REDEMPTION_99_II, -- redemption_99_ii (lv99)
            20884, -- redemption (lv99)
            20885, -- redemption (lv99)
            xi.item.REDEMPTION_119_III, -- redemption (lv99)
        },
    },
    -- [7] Polearm
    {
        wsUnlock = xi.wsUnlock.CAMLANNS_TORMENT,
        -- daboya (any level) or rhongomiant at level 90+
        items =
        {
            xi.item.DABOYA, -- daboya (lv99)
            20959, -- daboya_-1 (lv99)
            xi.item.RHONGOMIANT_90, -- rhongomiant_90 (lv90)
            xi.item.RHONGOMIANT_95, -- rhongomiant_95 (lv95)
            xi.item.RHONGOMIANT_99, -- rhongomiant_99 (lv99)
            xi.item.RHONGOMIANT_99_II, -- rhongomiant_99_ii (lv99)
            20929, -- rhongomiant (lv99)
            20930, -- rhongomiant (lv99)
            xi.item.RHONGOMIANT_119_III, -- rhongomiant (lv99)
        },
    },
    -- [8] Katana
    {
        wsUnlock = xi.wsUnlock.BLADE_HI,
        -- kasasagi (any level) or kannagi at level 90+
        items =
        {
            xi.item.KASASAGI, -- kasasagi (lv99)
            21001, -- kasasagi_-1 (lv99)
            xi.item.KANNAGI_90, -- kannagi_90 (lv90)
            xi.item.KANNAGI_95, -- kannagi_95 (lv95)
            xi.item.KANNAGI_99, -- kannagi_99 (lv99)
            xi.item.KANNAGI_99_II, -- kannagi_99_ii (lv99)
            20974, -- kannagi (lv99)
            20975, -- kannagi (lv99)
            xi.item.KANNAGI_119_III, -- kannagi (lv99)
        },
    },
    -- [9] Great Katana
    {
        wsUnlock = xi.wsUnlock.TACHI_FUDO,
        -- torigashiranotachi (any level) or masamune at level 90+
        items =
        {
            xi.item.TORIGASHIRANOTACHI, -- torigashiranotachi (lv99)
            21048, -- torigashiranotachi_-1 (lv99)
            xi.item.MASAMUNE_90, -- masamune_90 (lv90)
            xi.item.MASAMUNE_95, -- masamune_95 (lv95)
            xi.item.MASAMUNE_99, -- masamune_99 (lv99)
            xi.item.MASAMUNE_99_II, -- masamune_99_ii (lv99)
            21019, -- masamune (lv99)
            21020, -- masamune (lv99)
            xi.item.MASAMUNE_119_III, -- masamune (lv99)
        },
    },
    -- [10] Club
    {
        wsUnlock = xi.wsUnlock.DAGAN,
        -- rose_couverte (any level) or gambanteinn at level 90+
        items =
        {
            xi.item.ROSE_COUVERTE, -- rose_couverte (lv99)
            21121, -- rose_couverte_-1 (lv99)
            xi.item.GAMBANTEINN_90, -- gambanteinn_90 (lv90)
            xi.item.GAMBANTEINN_95, -- gambanteinn_95 (lv95)
            xi.item.GAMBANTEINN_99, -- gambanteinn_99 (lv99)
            xi.item.GAMBANTEINN_99_II, -- gambanteinn_99_ii (lv99)
            21064, -- gambanteinn (lv99)
            21065, -- gambanteinn (lv99)
            xi.item.GAMBANTEINN_119_III, -- gambanteinn (lv99)
        },
    },
    -- [11] Staff
    {
        wsUnlock = xi.wsUnlock.MYRKR,
        -- paikea (any level) or hvergelmir at level 90+
        items =
        {
            xi.item.PAIKEA, -- paikea (lv99)
            21187, -- paikea_-1 (lv99)
            xi.item.HVERGELMIR_90, -- hvergelmir_90 (lv90)
            xi.item.HVERGELMIR_95, -- hvergelmir_95 (lv95)
            xi.item.HVERGELMIR_99, -- hvergelmir_99 (lv99)
            xi.item.HVERGELMIR_99_II, -- hvergelmir_99_ii (lv99)
            21143, -- hvergelmir (lv99)
            21144, -- hvergelmir (lv99)
            xi.item.HVERGELMIR_119_III, -- hvergelmir (lv99)
        },
    },
    -- [12] Archery
    {
        wsUnlock = xi.wsUnlock.JISHNUS_RADIANCE,
        -- circinae (any level) or gandiva at level 90+
        items =
        {
            xi.item.CIRCINAE, -- circinae (lv99)
            21234, -- circinae_-1 (lv99)
            xi.item.GANDIVA_90, -- gandiva_90 (lv90)
            xi.item.GANDIVA_95, -- gandiva_95 (lv95)
            xi.item.GANDIVA_99, -- gandiva_99 (lv99)
            xi.item.GANDIVA_99_II, -- gandiva_99_ii (lv99)
            21212, -- gandiva (lv99)
            21213, -- gandiva (lv99)
            xi.item.GANDIVA_119_III, -- gandiva (lv99)
            xi.item.GANDIVA_119_III_NO_QUIVER, -- gandiva (lv99)
        },
    },
    -- [13] Marksmanship
    {
        wsUnlock = xi.wsUnlock.WILDFIRE,
        -- mollfrith (any level) or armageddon at level 90+
        items =
        {
            xi.item.MOLLFRITH, -- mollfrith (lv99)
            21283, -- mollfrith_-1 (lv99)
            xi.item.ARMAGEDDON_90, -- armageddon_90 (lv90)
            xi.item.ARMAGEDDON_95, -- armageddon_95 (lv95)
            xi.item.ARMAGEDDON_99, -- armageddon_99 (lv99)
            xi.item.ARMAGEDDON_99_II, -- armageddon_99_ii (lv99)
            21264, -- armageddon (lv99)
            21265, -- armageddon (lv99)
            xi.item.ARMAGEDDON_119_III, -- armageddon (lv99)
            xi.item.ARMAGEDDON_119_III_NO_QUIVER, -- armageddon (lv99)
        },
    },
}

local firstTimeCsid = 118
local repeatCsid    = 120
local transferCsid  = 122

-- Which type the player picked, carried from the menu event to the trade.
-- Stored +1 so that 0 means "nothing selected".
local selectionVar = 'KupofriedMoogleMagic'

local hasAnySkill = function(player)
    for _, entry in ipairs(weaponTypes) do
        if player:hasLearnedWeaponskill(entry.wsUnlock) then
            return true
        end
    end

    return false
end

xi.kupofriedMoogleMagic.onTrigger = function(player, npc)
    -- bg-wiki |Quest Reqs=Guardian of the Void on all fourteen pages.
    if not player:hasCompletedQuest(xi.questLog.CRYSTAL_WAR, xi.quest.id.crystalWar.GUARDIAN_OF_THE_VOID) then
        return false
    end

    -- 118 carries the whole preamble, 120 is the same menu without it, so 120
    -- is correct once the player has already been through this once.
    if hasAnySkill(player) or player:getCharVar(selectionVar) ~= 0 then
        player:startEvent(repeatCsid)
    else
        player:startEvent(firstTimeCsid)
    end

    return true
end

xi.kupofriedMoogleMagic.onTrade = function(player, npc, trade)
    local selected = player:getCharVar(selectionVar)
    if selected == 0 then
        return false
    end

    local entry = weaponTypes[selected]
    if entry == nil or player:hasLearnedWeaponskill(entry.wsUnlock) then
        return false
    end

    for _, itemId in ipairs(entry.items) do
        if npcUtil.tradeHasExactly(trade, itemId) then
            -- 8089 names the skill through ${choice: 0}, so the type index is
            -- param 0, which is startEvent's first vararg.
            player:startEvent(transferCsid, selected - 1)
            return true
        end
    end

    return false
end

xi.kupofriedMoogleMagic.onEventFinish = function(player, csid, option, npc)
    if csid == firstTimeCsid or csid == repeatCsid then
        -- 8075's last selection line is "None for the nonce", and 8078 offers
        -- "Verily. / Nay." -- anything that is not a real type clears the pick.
        if option < 0 or option > #weaponTypes - 1 then
            player:setCharVar(selectionVar, 0)
        else
            player:setCharVar(selectionVar, option + 1)
        end
    elseif csid == transferCsid then
        local entry = weaponTypes[player:getCharVar(selectionVar)]

        if entry ~= nil then
            player:confirmTrade()
            player:addLearnedWeaponskill(entry.wsUnlock)
            player:setCharVar(selectionVar, 0)
        end
    end
end
