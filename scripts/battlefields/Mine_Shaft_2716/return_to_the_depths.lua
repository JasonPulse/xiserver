-----------------------------------
-- Return to the Depths
-- Mine Shaft #2716 quest battlefield
-- Quest: Bastok "Return to the Depths" (id 78)
-----------------------------------
-- This script was the ONLY missing piece. Everything else already existed:
--   * `xi.battlefield.id.RETURN_TO_THE_DEPTHS = 737` (scripts/globals/battlefield.lua:289)
--   * `bcnm_records` row (737, 13, 'return_to_the_depths', 'nobody', 0, 1800)
--     -- sql/bcnm_info.sql:216. The 1800 is where timeLimit below comes from.
--   * Twilotak in all three mob tables: mob_pools 4057 (family 184),
--     mob_groups (6, 4057, 13, 'Twilotak'), and three spawn points
--     16830480 / 16830487 / 16830494, level 40, one per battlefield instance.
--   * The quest file's Mine Shaft section, which fires csid 5 at Prog 8 and then
--     waits on csid 32001 with `battlefieldWin == RETURN_TO_THE_DEPTHS` to set
--     Prog 10 and hand back the 10,000 gil.
-- Battlefields register through `scrapeSubdir("scripts/battlefields")`
-- (src/map/lua/luautils.cpp:583) and `xi.battlefield.contents[battlefieldId]`,
-- so with no Lua file the fight simply did not exist -- the player was warped in,
-- got the entry cutscene, and stopped. Prog never reached 10 and Ayame's reward
-- event was unreachable.
--
-- Retail (bg-wiki "Return to the Depths"):
--   "Trade one Ahriman Tears to Tarnotik to be teleported to Mine Shaft #2716
--    BCNM zone."
--   "Once in Mine Shaft #2716, select the Shaft Entrance twice for two cutscenes;
--    select in the affirmative both times."
--   "Defeat Twilotak to end the BCNM, and for a cutscene where you receive the
--    10,000 gil back."
--   Twilotak is a DRK and "such as Protect III and Regen" are cast on it.
--
-- index 1 is the only free client menu slot in this zone: century_of_hardship
-- takes 0, bionic_bug 2, automaton_assault 4, and 737 sits numerically between
-- 736 and 738.
--
-- NEEDS CONFIRMATION: maxPlayers and levelCap are taken from the two other
-- QUEST/MISSION-era battlefields in this same zone (century_of_hardship and
-- automaton_assault both use 6 / 60); bionic_bug's 18 / 75 is an ENM and not a
-- fair model. bg-wiki's page for this quest states neither value. timeLimit is
-- real data from bcnm_records, not a guess.
-----------------------------------
local content = BattlefieldQuest:new({
    zoneId        = xi.zone.MINE_SHAFT_2716,
    battlefieldId = xi.battlefield.id.RETURN_TO_THE_DEPTHS,
    maxPlayers    = 6,
    levelCap      = 60,
    timeLimit     = utils.minutes(30),
    index         = 1,
    entryNpc      = '_0d0',
    exitNpcs      = { '_0d1', '_0d2', '_0d3' },
    questArea     = xi.questLog.BASTOK,
    quest         = xi.quest.id.bastok.RETURN_TO_THE_DEPTHS,
    grantXP       = 1000,
})

-- Prog 9 is set by the quest's csid 5 handler, which only fires at Prog 8 -- i.e.
-- after Tarnotik has warped the player in and the two Shaft Entrance cutscenes
-- have been answered. Gating here on 9 keeps a player who wandered in by other
-- means from starting the fight early.
-- Only the Prog test is needed here: BattlefieldQuest:checkRequirements
-- (battlefield.lua:1482) calls Battlefield.checkRequirements first, which invokes
-- this hook at :618, and then applies its own
-- `getQuestStatus(questArea, quest) >= QUEST_ACCEPTED` at :1500. Repeating the
-- status check would be redundant.
function content:entryRequirement(player, npc, isRegistrant, trade)
    return xi.quest.getVar(player, xi.questLog.BASTOK, xi.quest.id.bastok.RETURN_TO_THE_DEPTHS, 'Prog') >= 9
end

-- Killing Twilotak is the whole win condition; bg-wiki: "Defeat Twilotak to end
-- the BCNM".
content:addEssentialMobs({ 'Twilotak' })

return content:register()
